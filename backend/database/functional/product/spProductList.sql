/**
 * @summary
 * Lists products in the catalog with pagination, filtering, and sorting.
 * Supports multiple filter criteria and ordering options.
 *
 * @procedure spProductList
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/product
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier for multi-tenancy
 *
 * @param {INT} page
 *   - Required: No
 *   - Description: Page number for pagination (default: 1)
 *
 * @param {INT} pageSize
 *   - Required: No
 *   - Description: Items per page (default: 12)
 *
 * @param {NVARCHAR(20)} sortBy
 *   - Required: No
 *   - Description: Sort criteria (default: 'relevancia')
 *
 * @param {NVARCHAR(MAX)} categories
 *   - Required: No
 *   - Description: Comma-separated category IDs
 *
 * @param {NVARCHAR(MAX)} flavors
 *   - Required: No
 *   - Description: Comma-separated flavor IDs
 *
 * @param {NVARCHAR(MAX)} sizes
 *   - Required: No
 *   - Description: Comma-separated size IDs
 *
 * @param {NUMERIC(18,6)} minPrice
 *   - Required: No
 *   - Description: Minimum price filter
 *
 * @param {NUMERIC(18,6)} maxPrice
 *   - Required: No
 *   - Description: Maximum price filter
 *
 * @param {NVARCHAR(MAX)} bakers
 *   - Required: No
 *   - Description: Comma-separated baker IDs
 *
 * @param {BIT} availableOnly
 *   - Required: No
 *   - Description: Filter only available products (default: 1)
 *
 * @param {NVARCHAR(100)} searchTerm
 *   - Required: No
 *   - Description: Search term for name, description, ingredients
 *
 * @testScenarios
 * - List all active products with default pagination
 * - Filter by category and price range
 * - Search by product name
 * - Sort by price and rating
 * - Filter by baker
 */
CREATE OR ALTER PROCEDURE [functional].[spProductList]
  @idAccount INT,
  @page INT = 1,
  @pageSize INT = 12,
  @sortBy NVARCHAR(20) = 'relevancia',
  @categories NVARCHAR(MAX) = NULL,
  @flavors NVARCHAR(MAX) = NULL,
  @sizes NVARCHAR(MAX) = NULL,
  @minPrice NUMERIC(18, 6) = NULL,
  @maxPrice NUMERIC(18, 6) = NULL,
  @bakers NVARCHAR(MAX) = NULL,
  @availableOnly BIT = 1,
  @searchTerm NVARCHAR(100) = NULL
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
   * @validation Page number validation
   * @throw {pageNumberMustBePositive}
   */
  IF (@page < 1)
  BEGIN
    ;THROW 51000, 'pageNumberMustBePositive', 1;
  END;

  /**
   * @validation Page size validation
   * @throw {pageSizeMustBeValid}
   */
  IF (@pageSize NOT IN (12, 24, 36))
  BEGIN
    SET @pageSize = 12;
  END;

  /**
   * @rule {be-multi-tenancy-pattern}
   * Calculate pagination offset
   */
  DECLARE @offset INT = (@page - 1) * @pageSize;

  /**
   * @rule {be-cte-pattern}
   * Build filtered product list with CTEs
   */
  WITH [FilteredProducts] AS (
    SELECT
      [prd].[idProduct],
      [prd].[name],
      [prd].[description],
      [prd].[basePrice],
      [prd].[promotionalPrice],
      [prd].[mainImage],
      [prd].[averageRating],
      [prd].[totalReviews],
      [prd].[preparationTime],
      [prd].[preparationTimeUnit],
      [prd].[active],
      [bkr].[name] AS [bakerName],
      [cat].[name] AS [categoryName],
      CASE
        WHEN [prd].[active] = 1 THEN 1
        ELSE 0
      END AS [available]
    FROM [functional].[product] [prd]
      JOIN [functional].[baker] [bkr] ON ([bkr].[idAccount] = [prd].[idAccount] AND [bkr].[idBaker] = [prd].[idBaker])
      LEFT JOIN [functional].[category] [cat] ON ([cat].[idAccount] = [prd].[idAccount] AND [cat].[idCategory] = [prd].[idCategory])
    WHERE [prd].[idAccount] = @idAccount
      AND [prd].[deleted] = 0
      AND [bkr].[deleted] = 0
      AND ([cat].[deleted] = 0 OR [cat].[deleted] IS NULL)
      AND (@availableOnly = 0 OR [prd].[active] = 1)
      AND (@categories IS NULL OR [prd].[idCategory] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@categories, ',')))
      AND (@bakers IS NULL OR [prd].[idBaker] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@bakers, ',')))
      AND (@minPrice IS NULL OR [prd].[basePrice] >= @minPrice)
      AND (@maxPrice IS NULL OR [prd].[basePrice] <= @maxPrice)
      AND (
        @searchTerm IS NULL
        OR [prd].[name] LIKE '%' + @searchTerm + '%'
        OR [prd].[description] LIKE '%' + @searchTerm + '%'
        OR [prd].[ingredients] LIKE '%' + @searchTerm + '%'
      )
  ),
  [SortedProducts] AS (
    SELECT
      *,
      ROW_NUMBER() OVER (
        ORDER BY
          CASE WHEN @sortBy = 'preco_menor' THEN [basePrice] END ASC,
          CASE WHEN @sortBy = 'preco_maior' THEN [basePrice] END DESC,
          CASE WHEN @sortBy = 'melhor_avaliados' THEN [averageRating] END DESC,
          CASE WHEN @sortBy = 'mais_recentes' THEN [idProduct] END DESC,
          [idProduct] ASC
      ) AS [rowNum]
    FROM [FilteredProducts]
  )
  /**
   * @output {ProductList, n, n}
   * @column {INT} idProduct - Product identifier
   * @column {NVARCHAR} name - Product name
   * @column {NVARCHAR} description - Product description
   * @column {NUMERIC} basePrice - Base price
   * @column {NUMERIC} promotionalPrice - Promotional price (nullable)
   * @column {NVARCHAR} mainImage - Main image URL
   * @column {NUMERIC} averageRating - Average rating
   * @column {INT} totalReviews - Total reviews count
   * @column {INT} preparationTime - Preparation time value
   * @column {VARCHAR} preparationTimeUnit - Preparation time unit
   * @column {BIT} available - Availability status
   * @column {NVARCHAR} bakerName - Baker name
   * @column {NVARCHAR} categoryName - Category name
   */
  SELECT
    [idProduct],
    [name],
    [description],
    [basePrice],
    [promotionalPrice],
    [mainImage],
    [averageRating],
    [totalReviews],
    [preparationTime],
    [preparationTimeUnit],
    [available],
    [bakerName],
    [categoryName]
  FROM [SortedProducts]
  WHERE [rowNum] > @offset AND [rowNum] <= (@offset + @pageSize)
  ORDER BY [rowNum];

  /**
   * @output {PaginationInfo, 1, n}
   * @column {INT} totalItems - Total items count
   * @column {INT} totalPages - Total pages count
   * @column {INT} currentPage - Current page number
   * @column {INT} pageSize - Items per page
   */
  SELECT
    COUNT(*) AS [totalItems],
    CEILING(CAST(COUNT(*) AS FLOAT) / @pageSize) AS [totalPages],
    @page AS [currentPage],
    @pageSize AS [pageSize]
  FROM [FilteredProducts];
END;
GO