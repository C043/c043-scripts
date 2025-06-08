#!/usr/bin/env node

import puppeteer from "puppeteer";
import { Mailsac } from "@mailsac/api";
import dotenv from "dotenv";
import { dirname, resolve } from "path";
import { fileURLToPath } from "url";

const _filename = fileURLToPath(import.meta.url);
const _dirname = dirname(_filename);
dotenv.config();
console.log(process.env.API_KEY);

const mailsac = new Mailsac({
  headers: { "Mailsac-Key": process.env.API_KEY }
});

const generateRandomAddress = (prefix = "endel") => {
  const random = Math.random().toString(36).substring(2, 10);
  return `${prefix}-${random}@mailsac.com`;
};

const readAddressInbox = async email => {
  const { data } = await mailsac.messages.listMessages(email);
  return data;
};

const email = generateRandomAddress();
console.log(`Using temporary email: ${email}`);

const wait = async ms => {
  return new Promise((resolve, reject) => setTimeout(resolve, ms));
};

const createAccount = async email => {
  const browser = await puppeteer.launch({ headless: false });
  const page = await browser.newPage();

  await page.goto("https://code.endel.io/?code=30daysfree");

  await wait(1000);

  await page.locator(".ButtonContent_text__mBTTs").click();
  await wait(1000);
  await page.locator(".ButtonContent_text__mBTTs").click();

  await wait(1000);
  await page
    .locator(
      "#__next > div.Popup_wrap__xTO_Y.Popup_true__LQ6s8 > div > div.Wrap_wrap__lYIgN.Wrap_small___tL01.Auth_wrap__1MMvx > form > button:nth-child(3) > div"
    )
    .click();

  await page.type(
    "#__next > div.Popup_wrap__xTO_Y.Popup_true__LQ6s8 > div > div.Wrap_wrap__lYIgN.Wrap_small___tL01.Auth_wrap__1MMvx > div.fadein > div.FormWrap_wrap__30Ofn.FormWrap_black__IzHjW > div > div > form > label > input",
    email
  );
  await wait(1000);
  await page
    .locator(
      "#__next > div.Popup_wrap__xTO_Y.Popup_true__LQ6s8 > div > div.Wrap_wrap__lYIgN.Wrap_small___tL01.Auth_wrap__1MMvx > div.fadein > div.FormWrap_wrap__30Ofn.FormWrap_black__IzHjW > div > div > form > button > div"
    )
    .click();

  console.log(`Messages:`);
  while (messagesReceived <= 0) {
    const messages = await readAddressInbox(email);
    console.log(messages);
  }

  return browser;
};

await createAccount(email);
console.log("Done");
