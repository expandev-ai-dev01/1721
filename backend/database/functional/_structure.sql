/**
 * @schema functional
 * Business entity schema for LoveCakes application
 */
CREATE SCHEMA [functional];
GO

/**
 * @table product Brief description: Stores cake products available in the catalog
 * @multitenancy true
 * @softDelete true
 * @alias prd
 */
CREATE TABLE [functional].[product] (
  [idProduct] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idBaker] INTEGER NOT NULL,
  [idCategory] INTEGER NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(500) NOT NULL DEFAULT (''),
  [ingredients] NVARCHAR(MAX) NOT NULL,
  [nutritionalInfo] NVARCHAR(MAX) NULL,
  [basePrice] NUMERIC(18, 6) NOT NULL,
  [promotionalPrice] NUMERIC(18, 6) NULL,
  [preparationTime] INTEGER NOT NULL,
  [preparationTimeUnit] VARCHAR(10) NOT NULL,
  [mainImage] NVARCHAR(500) NOT NULL,
  [imageGallery] NVARCHAR(MAX) NULL,
  [averageRating] NUMERIC(3, 2) NOT NULL DEFAULT (0.00),
  [totalReviews] INTEGER NOT NULL DEFAULT (0),
  [active] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table productFlavor Brief description: Stores available flavors for products
 * @multitenancy true
 * @softDelete true
 * @alias prdFlv
 */
CREATE TABLE [functional].[productFlavor] (
  [idProductFlavor] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(500) NOT NULL DEFAULT (''),
  [active] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table productSize Brief description: Stores available sizes for products
 * @multitenancy true
 * @softDelete true
 * @alias prdSz
 */
CREATE TABLE [functional].[productSize] (
  [idProductSize] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(500) NOT NULL DEFAULT (''),
  [servings] INTEGER NOT NULL,
  [priceAdjustment] NUMERIC(18, 6) NOT NULL DEFAULT (0.00),
  [active] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table productFlavorAvailability Brief description: Links products with available flavors
 * @multitenancy true
 * @softDelete false
 * @alias prdFlvAvl
 */
CREATE TABLE [functional].[productFlavorAvailability] (
  [idAccount] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [idProductFlavor] INTEGER NOT NULL,
  [available] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @table productSizeAvailability Brief description: Links products with available sizes
 * @multitenancy true
 * @softDelete false
 * @alias prdSzAvl
 */
CREATE TABLE [functional].[productSizeAvailability] (
  [idAccount] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [idProductSize] INTEGER NOT NULL,
  [available] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @table category Brief description: Stores product categories
 * @multitenancy true
 * @softDelete true
 * @alias cat
 */
CREATE TABLE [functional].[category] (
  [idCategory] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(500) NOT NULL DEFAULT (''),
  [active] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table baker Brief description: Stores baker/confectioner information
 * @multitenancy true
 * @softDelete true
 * @alias bkr
 */
CREATE TABLE [functional].[baker] (
  [idBaker] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [photo] NVARCHAR(500) NULL,
  [averageRating] NUMERIC(3, 2) NOT NULL DEFAULT (0.00),
  [totalSales] INTEGER NOT NULL DEFAULT (0),
  [active] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table productReview Brief description: Stores product reviews and ratings
 * @multitenancy true
 * @softDelete true
 * @alias prdRvw
 */
CREATE TABLE [functional].[productReview] (
  [idProductReview] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [idUser] INTEGER NOT NULL,
  [customerName] NVARCHAR(100) NOT NULL,
  [rating] INTEGER NOT NULL,
  [comment] NVARCHAR(1000) NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table cart Brief description: Stores shopping cart sessions
 * @multitenancy true
 * @softDelete false
 * @alias crt
 */
CREATE TABLE [functional].[cart] (
  [idCart] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idUser] INTEGER NULL,
  [sessionToken] NVARCHAR(100) NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @table cartItem Brief description: Stores items in shopping carts
 * @multitenancy true
 * @softDelete false
 * @alias crtItm
 */
CREATE TABLE [functional].[cartItem] (
  [idCartItem] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idCart] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [idProductFlavor] INTEGER NOT NULL,
  [idProductSize] INTEGER NOT NULL,
  [quantity] INTEGER NOT NULL,
  [unitPrice] NUMERIC(18, 6) NOT NULL,
  [totalPrice] NUMERIC(18, 6) NOT NULL,
  [notes] NVARCHAR(200) NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkProduct
 * @keyType Object
 */
ALTER TABLE [functional].[product]
ADD CONSTRAINT [pkProduct] PRIMARY KEY CLUSTERED ([idProduct]);
GO

/**
 * @primaryKey pkProductFlavor
 * @keyType Object
 */
ALTER TABLE [functional].[productFlavor]
ADD CONSTRAINT [pkProductFlavor] PRIMARY KEY CLUSTERED ([idProductFlavor]);
GO

/**
 * @primaryKey pkProductSize
 * @keyType Object
 */
ALTER TABLE [functional].[productSize]
ADD CONSTRAINT [pkProductSize] PRIMARY KEY CLUSTERED ([idProductSize]);
GO

/**
 * @primaryKey pkProductFlavorAvailability
 * @keyType Relationship
 */
ALTER TABLE [functional].[productFlavorAvailability]
ADD CONSTRAINT [pkProductFlavorAvailability] PRIMARY KEY CLUSTERED ([idAccount], [idProduct], [idProductFlavor]);
GO

/**
 * @primaryKey pkProductSizeAvailability
 * @keyType Relationship
 */
ALTER TABLE [functional].[productSizeAvailability]
ADD CONSTRAINT [pkProductSizeAvailability] PRIMARY KEY CLUSTERED ([idAccount], [idProduct], [idProductSize]);
GO

/**
 * @primaryKey pkCategory
 * @keyType Object
 */
ALTER TABLE [functional].[category]
ADD CONSTRAINT [pkCategory] PRIMARY KEY CLUSTERED ([idCategory]);
GO

/**
 * @primaryKey pkBaker
 * @keyType Object
 */
ALTER TABLE [functional].[baker]
ADD CONSTRAINT [pkBaker] PRIMARY KEY CLUSTERED ([idBaker]);
GO

/**
 * @primaryKey pkProductReview
 * @keyType Object
 */
ALTER TABLE [functional].[productReview]
ADD CONSTRAINT [pkProductReview] PRIMARY KEY CLUSTERED ([idProductReview]);
GO

/**
 * @primaryKey pkCart
 * @keyType Object
 */
ALTER TABLE [functional].[cart]
ADD CONSTRAINT [pkCart] PRIMARY KEY CLUSTERED ([idCart]);
GO

/**
 * @primaryKey pkCartItem
 * @keyType Object
 */
ALTER TABLE [functional].[cartItem]
ADD CONSTRAINT [pkCartItem] PRIMARY KEY CLUSTERED ([idCartItem]);
GO

/**
 * @foreignKey fkProduct_Baker Baker relationship
 * @target functional.baker
 */
ALTER TABLE [functional].[product]
ADD CONSTRAINT [fkProduct_Baker] FOREIGN KEY ([idBaker])
REFERENCES [functional].[baker]([idBaker]);
GO

/**
 * @foreignKey fkProduct_Category Category relationship
 * @target functional.category
 */
ALTER TABLE [functional].[product]
ADD CONSTRAINT [fkProduct_Category] FOREIGN KEY ([idCategory])
REFERENCES [functional].[category]([idCategory]);
GO

/**
 * @foreignKey fkProductFlavorAvailability_Product Product relationship
 * @target functional.product
 */
ALTER TABLE [functional].[productFlavorAvailability]
ADD CONSTRAINT [fkProductFlavorAvailability_Product] FOREIGN KEY ([idProduct])
REFERENCES [functional].[product]([idProduct]);
GO

/**
 * @foreignKey fkProductFlavorAvailability_Flavor Flavor relationship
 * @target functional.productFlavor
 */
ALTER TABLE [functional].[productFlavorAvailability]
ADD CONSTRAINT [fkProductFlavorAvailability_Flavor] FOREIGN KEY ([idProductFlavor])
REFERENCES [functional].[productFlavor]([idProductFlavor]);
GO

/**
 * @foreignKey fkProductSizeAvailability_Product Product relationship
 * @target functional.product
 */
ALTER TABLE [functional].[productSizeAvailability]
ADD CONSTRAINT [fkProductSizeAvailability_Product] FOREIGN KEY ([idProduct])
REFERENCES [functional].[product]([idProduct]);
GO

/**
 * @foreignKey fkProductSizeAvailability_Size Size relationship
 * @target functional.productSize
 */
ALTER TABLE [functional].[productSizeAvailability]
ADD CONSTRAINT [fkProductSizeAvailability_Size] FOREIGN KEY ([idProductSize])
REFERENCES [functional].[productSize]([idProductSize]);
GO

/**
 * @foreignKey fkProductReview_Product Product relationship
 * @target functional.product
 */
ALTER TABLE [functional].[productReview]
ADD CONSTRAINT [fkProductReview_Product] FOREIGN KEY ([idProduct])
REFERENCES [functional].[product]([idProduct]);
GO

/**
 * @foreignKey fkCartItem_Cart Cart relationship
 * @target functional.cart
 */
ALTER TABLE [functional].[cartItem]
ADD CONSTRAINT [fkCartItem_Cart] FOREIGN KEY ([idCart])
REFERENCES [functional].[cart]([idCart]);
GO

/**
 * @foreignKey fkCartItem_Product Product relationship
 * @target functional.product
 */
ALTER TABLE [functional].[cartItem]
ADD CONSTRAINT [fkCartItem_Product] FOREIGN KEY ([idProduct])
REFERENCES [functional].[product]([idProduct]);
GO

/**
 * @foreignKey fkCartItem_Flavor Flavor relationship
 * @target functional.productFlavor
 */
ALTER TABLE [functional].[cartItem]
ADD CONSTRAINT [fkCartItem_Flavor] FOREIGN KEY ([idProductFlavor])
REFERENCES [functional].[productFlavor]([idProductFlavor]);
GO

/**
 * @foreignKey fkCartItem_Size Size relationship
 * @target functional.productSize
 */
ALTER TABLE [functional].[cartItem]
ADD CONSTRAINT [fkCartItem_Size] FOREIGN KEY ([idProductSize])
REFERENCES [functional].[productSize]([idProductSize]);
GO

/**
 * @check chkProduct_Active Active status validation
 * @enum {0} Inactive
 * @enum {1} Active
 */
ALTER TABLE [functional].[product]
ADD CONSTRAINT [chkProduct_Active] CHECK ([active] IN (0, 1));
GO

/**
 * @check chkProduct_PreparationTimeUnit Time unit validation
 * @enum {hours} Hours
 * @enum {days} Days
 */
ALTER TABLE [functional].[product]
ADD CONSTRAINT [chkProduct_PreparationTimeUnit] CHECK ([preparationTimeUnit] IN ('hours', 'days'));
GO

/**
 * @check chkProductReview_Rating Rating range validation
 * @enum {1} 1 star
 * @enum {2} 2 stars
 * @enum {3} 3 stars
 * @enum {4} 4 stars
 * @enum {5} 5 stars
 */
ALTER TABLE [functional].[productReview]
ADD CONSTRAINT [chkProductReview_Rating] CHECK ([rating] BETWEEN 1 AND 5);
GO

/**
 * @index ixProduct_Account Multi-tenancy isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixProduct_Account]
ON [functional].[product]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixProduct_Account_Active Active products by account
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixProduct_Account_Active]
ON [functional].[product]([idAccount], [active])
INCLUDE ([name], [basePrice], [averageRating])
WHERE [deleted] = 0;
GO

/**
 * @index ixProduct_Account_Category Category filtering
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixProduct_Account_Category]
ON [functional].[product]([idAccount], [idCategory])
WHERE [deleted] = 0;
GO

/**
 * @index ixProduct_Account_Baker Baker filtering
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixProduct_Account_Baker]
ON [functional].[product]([idAccount], [idBaker])
WHERE [deleted] = 0;
GO

/**
 * @index ixProductFlavor_Account Multi-tenancy isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixProductFlavor_Account]
ON [functional].[productFlavor]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixProductSize_Account Multi-tenancy isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixProductSize_Account]
ON [functional].[productSize]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixCategory_Account Multi-tenancy isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixCategory_Account]
ON [functional].[category]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixBaker_Account Multi-tenancy isolation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixBaker_Account]
ON [functional].[baker]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixProductReview_Account_Product Product reviews lookup
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixProductReview_Account_Product]
ON [functional].[productReview]([idAccount], [idProduct])
INCLUDE ([rating], [dateCreated])
WHERE [deleted] = 0;
GO

/**
 * @index ixCart_Account_Session Session cart lookup
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixCart_Account_Session]
ON [functional].[cart]([idAccount], [sessionToken]);
GO

/**
 * @index ixCartItem_Account_Cart Cart items lookup
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixCartItem_Account_Cart]
ON [functional].[cartItem]([idAccount], [idCart]);
GO

/**
 * @index uqProduct_Account_Name Unique product name per account
 * @type Unique
 * @unique true
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqProduct_Account_Name]
ON [functional].[product]([idAccount], [name])
WHERE [deleted] = 0;
GO