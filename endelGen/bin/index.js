#!/usr/bin/env node

import puppeteer from "puppeteer";
import { Mailsac } from "@mailsac/api";
import dotenv from "dotenv";
import { dirname, parse, resolve } from "path";
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

const getMessageContent = async (email, messageId) => {
  const { data } = await mailsac.messages.getFullRawMessage(email, messageId);
  return data;
};

const wait = async ms => {
  return new Promise((resolve, reject) => setTimeout(resolve, ms));
};

const parseCodeFromEmail = text => {
  const match = text.match(/\b\d{4}-\d{4}-\d{4}\b/);
  const code = match ? match[0] : null;
  return code;
};

const getNewCode = async (email, messagesCount) => {
  let messagesReceived = messagesCount;
  while (messagesReceived <= messagesCount) {
    await wait(5000);
    const messages = await readAddressInbox(email);
    if (messages.length > messagesCount) {
      messagesReceived++;
      const fullMessage = await getMessageContent(
        email,
        messages[messages.length - 1]._id
      );
      const code = parseCodeFromEmail(fullMessage);
      console.log(`New code: ${code}`);
      return code;
    }
  }
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

  const code = await getNewCode(email, 0);
  await page.type(
    "#__next > div.Popup_wrap__xTO_Y.Popup_true__LQ6s8 > div > div.Wrap_wrap__lYIgN.Wrap_small___tL01.Auth_wrap__1MMvx > div > div.FormWrap_wrap__30Ofn.FormWrap_black__IzHjW > div > div > form > label > input",
    code
  );
  await wait(1000);
  await page
    .locator(
      "#__next > div.Popup_wrap__xTO_Y.Popup_true__LQ6s8 > div > div.Wrap_wrap__lYIgN.Wrap_small___tL01.Auth_wrap__1MMvx > div > div.FormWrap_wrap__30Ofn.FormWrap_black__IzHjW > div > div > form > button.Button_button__Ui8H1.Button_normal__stuQD.Button_border__wbP1B > div"
    )
    .click();
  await wait(1000);
  await page.type(
    "#__next > div.Popup_wrap__xTO_Y.Popup_true__LQ6s8 > div > div.Wrap_wrap__lYIgN.Wrap_small___tL01.Auth_wrap__1MMvx > div > div.FormWrap_wrap__30Ofn.FormWrap_black__IzHjW > div > div > form > label > input",
    "C043"
  );
  await page
    .locator(
      "#__next > div.Popup_wrap__xTO_Y.Popup_true__LQ6s8 > div > div.Wrap_wrap__lYIgN.Wrap_small___tL01.Auth_wrap__1MMvx > div > div.FormWrap_wrap__30Ofn.FormWrap_black__IzHjW > div > div > form > button > div"
    )
    .click();

  return browser;
};

const email = generateRandomAddress();
console.log(`Using temporary email: ${email}`);
await createAccount(email);
console.log("Done.");
