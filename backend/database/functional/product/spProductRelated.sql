/**
 * @summary
 * Retrieves related products based on specified criteria.
 * Prioritizes products from same category, baker, or by popularity.
 *
 * @procedure spProductRelated
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/product/:id/related
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier for multi-tenancy
 *
 * @param {INT} idProduct
 *   - Required: Yes
 *   - Description: Reference product identifier
 *
 * @param {INT} limit
 *   - Required: No
 *   - Description: Maximum number of related products (default: 4)
 *
 * @testScenarios
 * - Get related products by category
 * - Get related products by baker
 * - Fallback to popular products
 * - Exclude current product from results
 */
CREATE OR ALTER PROCEDURE [functional].[spProductRelated]
  @idAccount INT,
  @idProduct INT,
  @limit INT = 4
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
   * @rule {be-business-rule-validation}
   * Get reference product details
   */
  DECLARE @idCategory INT;
  DECLARE @idBaker INT;

  SELECT
    @idCategory = [idCategory],
    @idBaker = [idBaker]
  FROM [functional].[product]
  WHERE [idProduct] = @idProduct
    AND [idAccount] = @idAccount
    AND [deleted] = 0;

  /**
   * @rule {be-cte-pattern}
   * Build related products list with priority scoring
   */
  WITH [RelatedProducts] AS (
    SELECT
      [prd].[idProduct],
      [prd].[name],
      [prd].[basePrice],
      [prd].[promotionalPrice],
      [prd].[mainImage],
      [prd].[averageRating],
      [prd].[totalReviews],
      [bkr].[name] AS [bakerName],
      CASE
        WHEN [prd].[idCategory] = @idCategory AND [prd].[idBaker] = @idBaker THEN 3
        WHEN [prd].[idCategory] = @idCategory THEN 2
        WHEN [prd].[idBaker] = @idBaker THEN 1
        ELSE 0
      END AS [priority]
    FROM [functional].[product] [prd]
      JOIN [functional].[baker] [bkr] ON ([bkr].[idAccount] = [prd].[idAccount] AND [bkr].[idBaker] = [prd].[idBaker])
    WHERE [prd].[idAccount] = @idAccount
      AND [prd].[idProduct] <> @idProduct
      AND [prd].[active] = 1
      AND [prd].[deleted] = 0
      AND [bkr].[deleted] = 0
  )
  /**
   * @output {RelatedProducts, n, n}
   * @column {INT} idProduct - Product identifier
   * @column {NVARCHAR} name - Product name
   * @column {NUMERIC} basePrice - Base price
   * @column {NUMERIC} promotionalPrice - Promotional price (nullable)
   * @column {NVARCHAR} mainImage - Main image URL
   * @column {NUMERIC} averageRating - Average rating
   * @column {INT} totalReviews - Total reviews count
   * @column {NVARCHAR} bakerName - Baker name
   */
  SELECT TOP (@limit)
    [idProduct],
    [name],
    [basePrice],
    [promotionalPrice],
    [mainImage],
    [averageRating],
    [totalReviews],
    [bakerName]
  FROM [RelatedProducts]
  ORDER BY
    [priority] DESC,
    [averageRating] DESC,
    [totalReviews] DESC;
END;
GO