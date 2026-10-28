import type { RequestHandler } from "express";
import { ApiError } from "./error.js";
import type { TokenVerifier, VerifiedUser } from "./token-verifier.js";

declare module "express-serve-static-core" {
  interface Request {
    user?: VerifiedUser;
  }
}

function unauthorized(res: Parameters<RequestHandler>[1]): ApiError {
  res.setHeader("WWW-Authenticate", "Bearer");
  return new ApiError(401, "UNAUTHORIZED", "invalid token");
}

export function requireAuth(verifier: TokenVerifier): RequestHandler {
  return async (req, res, next) => {
    const authorization = req.get("authorization");
    const match = authorization?.match(/^Bearer\s+(\S+)$/i);
    const token = match?.[1];

    if (!token) {
      req.log.warn(
        { reason: "missing or malformed bearer token" },
        "Authentication failed",
      );
      throw unauthorized(res);
    }

    try {
      req.user = await verifier(token);
    } catch (error) {
      const reason =
        error instanceof Error ? error.message : "token verification failed";
      req.log.warn(
        { reason: reason.replaceAll(token, "[redacted]") },
        "Authentication failed",
      );
      throw unauthorized(res);
    }

    next();
  };
}
