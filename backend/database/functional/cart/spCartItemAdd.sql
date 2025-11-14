/**
 * @summary
 * Adds an item to the shopping cart or updates quantity if already exists.
 * Creates cart if it doesn't exist for the session.
 *
 * @procedure spCartItemAdd
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/cart/item
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier for multi-tenancy
 *
 * @param {INT} idUser
 *   - Required: No
 *   - Description: User identifier (nullable for guest carts)
 *
 * @param {NVARCHAR(100)} sessionToken
 *   - Required: Yes
 *   - Description: Session token for cart identification
 *
 * @param {INT} idProduct
 *   - Required: Yes
 *   - Description: Product identifier
 *
 * @param {INT} idProductFlavor
 *   - Required: Yes
 *   - Description: Selected flavor identifier
 *
 * @param {INT} idProductSize
 *   - Required: Yes
 *   - Description: Selected size identifier
 *
 * @param {INT} quantity
 *   - Required: Yes
 *   - Description: Quantity to add
 *
 * @param {NVARCHAR(200)} notes
 *   - Required: No
 *   - Description: Additional notes
 *
 * @testScenarios
 * - Add new item to cart
 * - Update quantity of existing item
 * - Create cart if doesn't exist
 * - Validate product availability
 * - Validate flavor and size availability
 * - Enforce quantity limits
 */
CREATE OR ALTER PROCEDURE [functional].[spCartItemAdd]
  @idAccount INT,
  @idUser INT = NULL,
  @sessionToken NVARCHAR(100),
  @idProduct INT,
  @idProductFlavor INT,
  @idProductSize INT,
  @quantity INT,
  @notes NVARCHAR(200) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @validation Required parameter validation
   * @throw {idAccountRequired}
   */
  IF (@idAccount IS NULL)
  BEGIN
    ;THROW 51000, 'idAccountRequired', 1;
  END;

  /**
   * @validation Required parameter validation
   * @throw {sessionTokenRequired}
   */
  IF (@sessionToken IS NULL OR @sessionToken = '')
  BEGIN
    ;THROW 51000, 'sessionTokenRequired', 1;
  END;

  /**
   * @validation Required parameter validation
   * @throw {idProductRequired}
   */
  IF (@idProduct IS NULL)
  BEGIN
    ;THROW 51000, 'idProductRequired', 1;
  END;

  /**
   * @validation Required parameter validation
   * @throw {flavorRequired}
   */
  IF (@idProductFlavor IS NULL)
  BEGIN
    ;THROW 51000, 'flavorRequired', 1;
  END;

  /**
   * @validation Required parameter validation
   * @throw {sizeRequired}
   */
  IF (@idProductSize IS NULL)
  BEGIN
    ;THROW 51000, 'sizeRequired', 1;
  END;

  /**
   * @validation Quantity validation
   * @throw {quantityMustBePositive}
   */
  IF (@quantity < 1)
  BEGIN
    ;THROW 51000, 'quantityMustBePositive', 1;
  END;

  /**
   * @validation Quantity limit validation
   * @throw {quantityExceedsMaximum}
   */
  IF (@quantity > 10)
  BEGIN
    ;THROW 51000, 'quantityExceedsMaximum', 1;
  END;

  /**
   * @validation Product availability validation
   * @throw {productNotAvailable}
   */
  IF NOT EXISTS (
    SELECT *
    FROM [functional].[product] [prd]
    WHERE [prd].[idProduct] = @idProduct
      AND [prd].[idAccount] = @idAccount
      AND [prd].[active] = 1
      AND [prd].[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'productNotAvailable', 1;
  END;

  /**
   * @validation Flavor availability validation
   * @throw {flavorNotAvailable}
   */
  IF NOT EXISTS (
    SELECT *
    FROM [functional].[productFlavorAvailability] [flvAvl]
      JOIN [functional].[productFlavor] [flv] ON ([flv].[idAccount] = [flvAvl].[idAccount] AND [flv].[idProductFlavor] = [flvAvl].[idProductFlavor])
    WHERE [flvAvl].[idAccount] = @idAccount
      AND [flvAvl].[idProduct] = @idProduct
      AND [flvAvl].[idProductFlavor] = @idProductFlavor
      AND [flvAvl].[available] = 1
      AND [flv].[active] = 1
      AND [flv].[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'flavorNotAvailable', 1;
  END;

  /**
   * @validation Size availability validation
   * @throw {sizeNotAvailable}
   */
  IF NOT EXISTS (
    SELECT *
    FROM [functional].[productSizeAvailability] [szAvl]
      JOIN [functional].[productSize] [sz] ON ([sz].[idAccount] = [szAvl].[idAccount] AND [sz].[idProductSize] = [szAvl].[idProductSize])
    WHERE [szAvl].[idAccount] = @idAccount
      AND [szAvl].[idProduct] = @idProduct
      AND [szAvl].[idProductSize] = @idProductSize
      AND [szAvl].[available] = 1
      AND [sz].[active] = 1
      AND [sz].[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'sizeNotAvailable', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

    /**
     * @rule {be-transaction-control-pattern}
     * Get or create cart
     */
    DECLARE @idCart INT;

    SELECT @idCart = [idCart]
    FROM [functional].[cart]
    WHERE [idAccount] = @idAccount
      AND [sessionToken] = @sessionToken;

    IF (@idCart IS NULL)
    BEGIN
      INSERT INTO [functional].[cart] ([idAccount], [idUser], [sessionToken])
      VALUES (@idAccount, @idUser, @sessionToken);

      SET @idCart = SCOPE_IDENTITY();
    END;

    /**
     * @rule {be-business-rule-validation}
     * Calculate prices
     */
    DECLARE @basePrice NUMERIC(18, 6);
    DECLARE @promotionalPrice NUMERIC(18, 6);
    DECLARE @priceAdjustment NUMERIC(18, 6);
    DECLARE @unitPrice NUMERIC(18, 6);
    DECLARE @totalPrice NUMERIC(18, 6);

    SELECT
      @basePrice = [prd].[basePrice],
      @promotionalPrice = [prd].[promotionalPrice]
    FROM [functional].[product] [prd]
    WHERE [prd].[idProduct] = @idProduct
      AND [prd].[idAccount] = @idAccount;

    SELECT @priceAdjustment = [priceAdjustment]
    FROM [functional].[productSize]
    WHERE [idProductSize] = @idProductSize
      AND [idAccount] = @idAccount;

    SET @unitPrice = ISNULL(@promotionalPrice, @basePrice) + @priceAdjustment;
    SET @totalPrice = @unitPrice * @quantity;

    /**
     * @rule {be-business-rule-validation}
     * Check if item already exists in cart
     */
    DECLARE @existingIdCartItem INT;
    DECLARE @existingQuantity INT;

    SELECT
      @existingIdCartItem = [idCartItem],
      @existingQuantity = [quantity]
    FROM [functional].[cartItem]
    WHERE [idAccount] = @idAccount
      AND [idCart] = @idCart
      AND [idProduct] = @idProduct
      AND [idProductFlavor] = @idProductFlavor
      AND [idProductSize] = @idProductSize;

    IF (@existingIdCartItem IS NOT NULL)
    BEGIN
      /**
       * @rule {be-business-rule-validation}
       * Update existing item quantity
       */
      DECLARE @newQuantity INT = @existingQuantity + @quantity;

      IF (@newQuantity > 10)
      BEGIN
        ;THROW 51000, 'quantityExceedsMaximum', 1;
      END;

      UPDATE [functional].[cartItem]
      SET
        [quantity] = @newQuantity,
        [totalPrice] = @unitPrice * @newQuantity,
        [notes] = ISNULL(@notes, [notes]),
        [dateModified] = GETUTCDATE()
      WHERE [idCartItem] = @existingIdCartItem;

      SELECT @existingIdCartItem AS [idCartItem];
    END
    ELSE
    BEGIN
      /**
       * @rule {be-transaction-control-pattern}
       * Insert new cart item
       */
      INSERT INTO [functional].[cartItem] (
        [idAccount],
        [idCart],
        [idProduct],
        [idProductFlavor],
        [idProductSize],
        [quantity],
        [unitPrice],
        [totalPrice],
        [notes]
      )
      VALUES (
        @idAccount,
        @idCart,
        @idProduct,
        @idProductFlavor,
        @idProductSize,
        @quantity,
        @unitPrice,
        @totalPrice,
        @notes
      );

      SELECT SCOPE_IDENTITY() AS [idCartItem];
    END;

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO