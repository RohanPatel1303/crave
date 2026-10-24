import type { ErrorRequestHandler, RequestHandler } from "express";
import { ZodError } from "zod";

type ErrorEnvelope = {
  code: string;
  message: string;
  requestId: string;
};

export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "ApiError";
  }
}

function requestIdFor(req: Parameters<ErrorRequestHandler>[1]): string {
  if (typeof req.id === "string") return req.id;
  if (typeof req.id === "number") return req.id.toString();
  return "unknown";
}

export const notFoundHandler: RequestHandler = (req, res) => {
  const body: ErrorEnvelope = {
    code: "NOT_FOUND",
    message: "Route not found",
    requestId: requestIdFor(req),
  };
  res.status(404).json(body);
};

export const errorHandler: ErrorRequestHandler = (error, req, res, next) => {
  if (res.headersSent) {
    next(error);
    return;
  }

  const requestId = requestIdFor(req);

  if (error instanceof ApiError) {
    const body: ErrorEnvelope = {
      code: error.code,
      message: error.message,
      requestId,
    };

    res.status(error.status).json(body);
    return;
  }

  if (error instanceof ZodError) {
    const body: ErrorEnvelope = {
      code: "VALIDATION",
      message: "Request validation failed",
      requestId,
    };

    res.status(400).json(body);
    return;
  }

  req.log.error({ err: error }, "Unhandled request error");

  const body: ErrorEnvelope = {
    code: "INTERNAL",
    message: "Something went wrong",
    requestId,
  };
  res.status(500).json(body);
};
