/**
 * @summary
 * Zod validation utilities.
 * Provides reusable validation schemas and helpers.
 *
 * @module utils/zodValidation
 */
import { z } from 'zod';

/**
 * @constant zBit
 * @description Boolean bit validation (0 or 1)
 */
export const zBit = z.number().int().min(0).max(1);

/**
 * @constant zFK
 * @description Foreign key validation (positive integer)
 */
export const zFK = z.number().int().positive();

/**
 * @constant zNullableFK
 * @description Nullable foreign key validation
 */
export const zNullableFK = z.number().int().positive().nullable();

/**
 * @constant zString
 * @description Non-empty string validation
 */
export const zString = z.string().min(1);

/**
 * @constant zNullableString
 * @description Nullable string validation
 */
export const zNullableString = z.string().nullable();

/**
 * @constant zName
 * @description Name field validation (1-200 characters)
 */
export const zName = z.string().min(1).max(200);

/**
 * @constant zNullableDescription
 * @description Description field validation (max 500 characters, nullable)
 */
export const zNullableDescription = z.string().max(500).nullable();

/**
 * @constant zDateString
 * @description Date string validation
 */
export const zDateString = z.string().datetime();

/**
 * @constant zEmail
 * @description Email validation
 */
export const zEmail = z.string().email();

/**
 * @constant zPrice
 * @description Price validation (positive number with 2 decimals)
 */
export const zPrice = z.number().positive();

/**
 * @constant zNullablePrice
 * @description Nullable price validation
 */
export const zNullablePrice = z.number().positive().nullable();
