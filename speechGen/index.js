import puppeteer from "puppeteer";
import dotenv from "dotenv";
dotenv.config();

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

  await new Promise((resolve, reject) => setTimeout(resolve, 5000));

  await page
    .locator(
      "body > div.bg-glass-0.min-h-screen.w-full > div > main > div > div.flex-grow.flex.items-start.justify-center > div > div > div.flex.flex-col.w-full > form > div:nth-child(5) > p > button"
    )
    .click();
  await page.type('input[type="email"]', email.address);
  await page.type('input[type="password"]', process.env.PASSWORD);

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
