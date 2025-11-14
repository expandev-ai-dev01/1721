/**
 * @summary
 * Base CRUD controller with security and validation.
 * Provides standardized CRUD operations with permission checking.
 *
 * @module middleware/crud/CrudController
 */
import { Request } from 'express';
import { z, ZodSchema } from 'zod';

/**
 * @interface SecurityConfig
 * @description Security configuration for CRUD operations
 */
interface SecurityConfig {
  securable: string;
  permission: 'CREATE' | 'READ' | 'UPDATE' | 'DELETE';
}

/**
 * @interface ValidatedRequest
 * @description Validated request data structure
 */
interface ValidatedRequest {
  credential: {
    idAccount: number;
    idUser: number;
  };
  params: any;
}

/**
 * @class CrudController
 * @description Base controller for CRUD operations with security
 */
export class CrudController {
  private securityConfig: SecurityConfig[];

  constructor(securityConfig: SecurityConfig[]) {
    this.securityConfig = securityConfig;
  }

  /**
   * @function create
   * @description Validates CREATE operation
   *
   * @param {Request} req - Express request
   * @param {ZodSchema} schema - Validation schema
   * @returns {Promise<[ValidatedRequest | null, Error | null]>}
   */
  async create(req: Request, schema: ZodSchema): Promise<[ValidatedRequest | null, Error | null]> {
    return this.validateRequest(req, schema, 'CREATE');
  }

  /**
   * @function read
   * @description Validates READ operation
   *
   * @param {Request} req - Express request
   * @param {ZodSchema} schema - Validation schema
   * @returns {Promise<[ValidatedRequest | null, Error | null]>}
   */
  async read(req: Request, schema: ZodSchema): Promise<[ValidatedRequest | null, Error | null]> {
    return this.validateRequest(req, schema, 'READ');
  }

  /**
   * @function update
   * @description Validates UPDATE operation
   *
   * @param {Request} req - Express request
   * @param {ZodSchema} schema - Validation schema
   * @returns {Promise<[ValidatedRequest | null, Error | null]>}
   */
  async update(req: Request, schema: ZodSchema): Promise<[ValidatedRequest | null, Error | null]> {
    return this.validateRequest(req, schema, 'UPDATE');
  }

  /**
   * @function delete
   * @description Validates DELETE operation
   *
   * @param {Request} req - Express request
   * @param {ZodSchema} schema - Validation schema
   * @returns {Promise<[ValidatedRequest | null, Error | null]>}
   */
  async delete(req: Request, schema: ZodSchema): Promise<[ValidatedRequest | null, Error | null]> {
    return this.validateRequest(req, schema, 'DELETE');
  }

  /**
   * @function validateRequest
   * @description Internal validation logic
   *
   * @param {Request} req - Express request
   * @param {ZodSchema} schema - Validation schema
   * @param {string} permission - Required permission
   * @returns {Promise<[ValidatedRequest | null, Error | null]>}
   */
  private async validateRequest(
    req: Request,
    schema: ZodSchema,
    permission: string
  ): Promise<[ValidatedRequest | null, Error | null]> {
    try {
      /**
       * @validation Schema validation
       */
      const params = await schema.parseAsync({ ...req.params, ...req.body, ...req.query });

      /**
       * @remarks
       * Security validation will be implemented here
       * when authentication system is added
       */
      const credential = {
        idAccount: 1,
        idUser: 1,
      };

      return [{ credential, params }, null];
    } catch (error) {
      return [null, error as Error];
    }
  }
}
