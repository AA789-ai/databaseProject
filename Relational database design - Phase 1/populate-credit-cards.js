require("dotenv").config();
const { Pool } = require("pg");

const pool = new Pool({
  user: process.env.user,
  database: process.env.database,
  password: process.env.password,
  port: process.env.port,
  host: process.env.host,
});

const fetchCreditCards = async (userID) => {
  const req = await fetch(
    "https://random-data-api.com/api/v2/credit_cards?size=1"
  );
  const data = await req.json();

  const [number, expiry, type] = [
    data["credit_card_number"],
    data["credit_card_expiry_date"],
    data["credit_card_type"],
  ];
  console.log({ number, expiry, type });

  const query1 = `INSERT INTO Card(personID, number, expiration, type) VALUES ($1, $2, $3, $4)`;
  try {
    await pool.query(query1, [userID, number, expiry, type]);
  } catch (err) {
    console.log("err from card insert", err);
  }

  const rand = Math.random();
  const cardQuery = await pool.query(`SELECT id FROM Card WHERE number = $1`, [
    number,
  ]);
  const cardID = cardQuery["rows"][0]["id"];
  console.log({ cardID });

  if (rand < 0.5) {
    // insert into credit card
    const creditLimit = (Math.random() * 1000000 + 1000).toFixed(2);
    const availableCredit = (Math.random() * 1000000 + 1000).toFixed(2);
    const query2 = `INSERT INTO CreditCard (cardID, creditLimit, availableCredit) VALUES ($1, $2, $3)`;
    console.log({ cardID, creditLimit, availableCredit });
    try {
      await pool.query(query2, [cardID, creditLimit, availableCredit]);
    } catch (err) {
      console.log("err from credit insert ", err);
    }
  } else {
    // insert into debit card
    const balance = (Math.random() * 10000 + 1000).toFixed(2);
    const query2 = `INSERT INTO DebitCard (cardID, balance) VALUES ($1, $2);`;
    console.log({ cardID, balance });
    try {
      await pool.query(query2, [cardID, balance]);
    } catch (err) {
      console.log("err from debit insert ", err);
    }
  }
};

const generateCardForRandomUser = () => {
  const userID = Math.floor(Math.random() * 3900 + 1);
  fetchCreditCards(userID);
};

generateCardForRandomUser();
