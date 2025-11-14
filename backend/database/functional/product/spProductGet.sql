/**
 * @summary
 * Retrieves detailed information for a specific product.
 * Includes product details, available flavors, sizes, reviews, and baker information.
 *
 * @procedure spProductGet
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/product/:id
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier for multi-tenancy
 *
 * @param {INT} idProduct
 *   - Required: Yes
 *   - Description: Product identifier
 *
 * @testScenarios
 * - Get product details with all related data
 * - Validate product exists and is active
 * - Retrieve available flavors and sizes
 * - Get product reviews
 */
CREATE OR ALTER PROCEDURE [functional].[spProductGet]
  @idAccount INT,
  @idProduct INT
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
   * @throw {idProductRequired}
   */
  IF (@idProduct IS NULL)
  BEGIN
    ;THROW 51000, 'idProductRequired', 1;
  END;

  /**
   * @validation Product existence validation
   * @throw {productDoesntExist}
   */
  IF NOT EXISTS (
    SELECT *
    FROM [functional].[product] [prd]
    WHERE [prd].[idProduct] = @idProduct
      AND [prd].[idAccount] = @idAccount
      AND [prd].[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'productDoesntExist', 1;
  END;

  /**
   * @output {ProductDetails, 1, n}
   * @column {INT} idProduct - Product identifier
   * @column {NVARCHAR} name - Product name
   * @column {NVARCHAR} description - Product description
   * @column {NVARCHAR} ingredients - Product ingredients
   * @column {NVARCHAR} nutritionalInfo - Nutritional information (JSON)
   * @column {NUMERIC} basePrice - Base price
   * @column {NUMERIC} promotionalPrice - Promotional price (nullable)
   * @column {NVARCHAR} mainImage - Main image URL
   * @column {NVARCHAR} imageGallery - Image gallery URLs (JSON)
   * @column {NUMERIC} averageRating - Average rating
   * @column {INT} totalReviews - Total reviews count
   * @column {INT} preparationTime - Preparation time value
   * @column {VARCHAR} preparationTimeUnit - Preparation time unit
   * @column {BIT} available - Availability status
   * @column {INT} idBaker - Baker identifier
   * @column {NVARCHAR} bakerName - Baker name
   * @column {NVARCHAR} bakerPhoto - Baker photo URL
   * @column {NUMERIC} bakerRating - Baker average rating
   * @column {INT} bakerTotalSales - Baker total sales
   */
  SELECT
    [prd].[idProduct],
    [prd].[name],
    [prd].[description],
    [prd].[ingredients],
    [prd].[nutritionalInfo],
    [prd].[basePrice],
    [prd].[promotionalPrice],
    [prd].[mainImage],
    [prd].[imageGallery],
    [prd].[averageRating],
    [prd].[totalReviews],
    [prd].[preparationTime],
    [prd].[preparationTimeUnit],
    [prd].[active] AS [available],
    [bkr].[idBaker],
    [bkr].[name] AS [bakerName],
    [bkr].[photo] AS [bakerPhoto],
    [bkr].[averageRating] AS [bakerRating],
    [bkr].[totalSales] AS [bakerTotalSales]
  FROM [functional].[product] [prd]
    JOIN [functional].[baker] [bkr] ON ([bkr].[idAccount] = [prd].[idAccount] AND [bkr].[idBaker] = [prd].[idBaker])
  WHERE [prd].[idProduct] = @idProduct
    AND [prd].[idAccount] = @idAccount
    AND [prd].[deleted] = 0;

  /**
   * @output {AvailableFlavors, n, n}
   * @column {INT} idProductFlavor - Flavor identifier
   * @column {NVARCHAR} name - Flavor name
   * @column {NVARCHAR} description - Flavor description
   */
  SELECT
    [flv].[idProductFlavor],
    [flv].[name],
    [flv].[description]
  FROM [functional].[productFlavorAvailability] [flvAvl]
    JOIN [functional].[productFlavor] [flv] ON ([flv].[idAccount] = [flvAvl].[idAccount] AND [flv].[idProductFlavor] = [flvAvl].[idProductFlavor])
  WHERE [flvAvl].[idAccount] = @idAccount
    AND [flvAvl].[idProduct] = @idProduct
    AND [flvAvl].[available] = 1
    AND [flv].[active] = 1
    AND [flv].[deleted] = 0;

  /**
   * @output {AvailableSizes, n, n}
   * @column {INT} idProductSize - Size identifier
   * @column {NVARCHAR} name - Size name
   * @column {NVARCHAR} description - Size description
   * @column {INT} servings - Number of servings
   * @column {NUMERIC} priceAdjustment - Price adjustment
   */
  SELECT
    [sz].[idProductSize],
    [sz].[name],
    [sz].[description],
    [sz].[servings],
    [sz].[priceAdjustment]
  FROM [functional].[productSizeAvailability] [szAvl]
    JOIN [functional].[productSize] [sz] ON ([sz].[idAccount] = [szAvl].[idAccount] AND [sz].[idProductSize] = [szAvl].[idProductSize])
  WHERE [szAvl].[idAccount] = @idAccount
    AND [szAvl].[idProduct] = @idProduct
    AND [szAvl].[available] = 1
    AND [sz].[active] = 1
    AND [sz].[deleted] = 0;

  /**
   * @output {ProductReviews, n, n}
   * @column {INT} idProductReview - Review identifier
   * @column {NVARCHAR} customerName - Customer name
   * @column {INT} rating - Rating (1-5)
   * @column {NVARCHAR} comment - Review comment
   * @column {DATETIME2} dateCreated - Review date
   */
  SELECT
    [rvw].[idProductReview],
    [rvw].[customerName],
    [rvw].[rating],
    [rvw].[comment],
    [rvw].[dateCreated]
  FROM [functional].[productReview] [rvw]
  WHERE [rvw].[idAccount] = @idAccount
    AND [rvw].[idProduct] = @idProduct
    AND [rvw].[deleted] = 0
  ORDER BY [rvw].[dateCreated] DESC;
END;
GO