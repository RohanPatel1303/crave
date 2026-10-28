import { jwtVerify, type JWTVerifyGetKey, type KeyInput } from "jose";

export type VerifiedUser = {
  id: string;
  email: string;
};

export type TokenVerifier = (token: string) => Promise<VerifiedUser>;

export function createTokenVerifier(
  key: KeyInput | JWTVerifyGetKey,
  issuer: string,
  audience: string,
): TokenVerifier {
  return async (token) => {
    const { payload } = await jwtVerify(token, key, {
      issuer,
      audience,
      algorithms: ["RS256"],
    });

    if (
      typeof payload.sub !== "string" ||
      payload.sub.length === 0 ||
      typeof payload.email !== "string" ||
      payload.email.trim().length === 0
    ) {
      throw new Error("Verified token is missing required identity claims");
    }

    return { id: payload.sub, email: payload.email };
  };
}
