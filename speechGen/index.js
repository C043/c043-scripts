#!/usr/bin/env node

import puppeteer from "puppeteer";
import dotenv from "dotenv";
import { dirname, resolve } from "path";
import { fileURLToPath } from "url";

const _filename = fileURLToPath(import.meta.url);
const _dirname = dirname(_filename);
dotenv.config({ path: resolve(_dirname, ".env") });

function generateEmail() {
  const name = Math.random().toString(36).substring(2, 11);
  return {
    login: name,
    domain: "1secmail.com",
    address: `${name}@1secmail.com`
  };
}

async function createAccount(email) {
  const browser = await puppeteer.launch({ headless: false });
  const page = await browser.newPage();

  await page.goto(
    "https://speechify.com/onboarding/mobile/quiz/general/paywall/?source_page=_&source_category=home&source_locale=en&selected=gwyneth&speed=300"
  );

  await new Promise((resolve, reject) => setTimeout(resolve, 3000));

  await page
    .locator(
      "body > div.bg-glass-0.min-h-screen.w-full > div > main > div > div.flex-grow.flex.items-start.justify-center > div > div > div.flex.flex-col.w-full > form > div:nth-child(5) > p > button"
    )
    .click();
  await page.type('input[type="email"]', email.address);

  await page.type('input[type="password"]', process.env.PASSWORD);

  await new Promise((resolve, reject) => setTimeout(resolve, 500));

  await page.click('button[type="submit"]');

  return browser;
}

(async () => {
  try {
    const email = generateEmail();
    console.log("Using temp email: ", email.address);

    await createAccount(email);
    console.log("Done.");
  } catch (err) {
    console.error(err);
  }
})();
