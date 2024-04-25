import express, { Express, Request, Response } from "express";
import dotenv from "dotenv";
import { createChallenge, verifySolution } from "altcha-lib";
import helmet from "helmet";
import chalk from "chalk";

(async () => {
  dotenv.config();

  const app: Express = express();
  app.use(helmet());

  const port = process.env.PORT || 3000;
  const hmacKey = process.env.SECRET as string;

  if (hmacKey == "$ecret.key") console.log(chalk.white.bgRed.bold(" [WARNING] CHANGE ALTCHA SECRET KEY - its still default !!! "));

  app.get("/", (req: Request, res: Response) => {
    res.send("Hello World!");
  });

  app.get("/challenge", async (req: Request, res: Response) => {
    const challenge = await createChallenge({ hmacKey });
    console.log(challenge);
    res.status(200).json(challenge);
  });

  app.listen(port, () => {
    console.log(`[ALTCHA]: Captcha Server is running at http://localhost:${port}`);
  });
})();
