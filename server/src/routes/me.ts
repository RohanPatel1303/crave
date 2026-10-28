import { Router } from "express";

const router = Router();

router.get("/me", (req, res) => {
  res.status(200).json(req.user);
});

export default router;
