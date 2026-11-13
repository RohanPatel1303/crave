import type { CatalogData } from "./schema.js";

function usd(minorUnits: number) {
  return { minorUnits, currency: "USD" };
}

export const seed: CatalogData = {
  restaurants: [
    { id: "taqueria-sol", name: "Taqueria Sol", cuisine: "Mexican" },
    { id: "nonna-rosa", name: "Nonna Rosa", cuisine: "Italian" },
    { id: "green-bowl", name: "Green Bowl", cuisine: "Salads" },
  ],
  menus: [
    {
      restaurantId: "taqueria-sol",
      currency: "USD",
      categories: [
        {
          id: "tacos",
          name: "Tacos",
          items: [
            {
              id: "al-pastor",
              name: "Al pastor taco",
              description: "Pork, pineapple, onion, cilantro",
              price: usd(450),
              available: true,
            },
            {
              id: "carne-asada",
              name: "Carne asada taco",
              description: "Grilled steak, salsa verde, onion",
              price: usd(500),
              available: true,
            },
            {
              id: "pollo",
              name: "Pollo taco",
              description: "Chipotle chicken, pickled onion, crema",
              price: usd(425),
              available: true,
            },
            {
              id: "hongos",
              name: "Hongos taco",
              description: "Roasted mushrooms, queso fresco, epazote",
              price: usd(400),
              available: true,
            },
          ],
        },
        {
          id: "sides",
          name: "Sides",
          items: [
            {
              id: "chips-guacamole",
              name: "Chips and guacamole",
              description: "Fresh tortilla chips with house guacamole",
              price: usd(650),
              available: true,
            },
            {
              id: "elote",
              name: "Elote",
              description: "Grilled corn, mayo, cotija, chili",
              price: usd(475),
              available: true,
            },
            {
              id: "rice-beans",
              name: "Rice and beans",
              description: "Red rice and black beans",
              price: usd(350),
              available: true,
            },
            {
              id: "churros",
              name: "Churros",
              description: "Cinnamon sugar churros with chocolate",
              price: usd(550),
              available: true,
            },
          ],
        },
      ],
    },
    {
      restaurantId: "nonna-rosa",
      currency: "USD",
      categories: [
        {
          id: "antipasti",
          name: "Antipasti",
          items: [
            {
              id: "bruschetta",
              name: "Bruschetta",
              description: "Tomato, basil, garlic, olive oil",
              price: usd(850),
              available: true,
            },
            {
              id: "arancini",
              name: "Arancini",
              description: "Fried risotto balls with mozzarella",
              price: usd(950),
              available: true,
            },
            {
              id: "caprese",
              name: "Caprese",
              description: "Mozzarella, tomato, basil",
              price: usd(1050),
              available: true,
            },
            {
              id: "burrata",
              name: "Burrata",
              description: "Burrata, roasted peppers, grilled bread",
              price: usd(1400),
              available: false,
            },
          ],
        },
        {
          id: "pasta",
          name: "Pasta",
          items: [
            {
              id: "cacio-e-pepe",
              name: "Cacio e pepe",
              description: "Tonnarelli, pecorino, black pepper",
              price: usd(1600),
              available: true,
            },
            {
              id: "carbonara",
              name: "Carbonara",
              description: "Rigatoni, guanciale, egg yolk, pecorino",
              price: usd(1750),
              available: true,
            },
            {
              id: "bolognese",
              name: "Tagliatelle bolognese",
              description: "Slow-cooked beef and pork ragu",
              price: usd(1800),
              available: true,
            },
            {
              id: "pesto",
              name: "Trofie al pesto",
              description: "Basil pesto, green beans, potato",
              price: usd(1550),
              available: true,
            },
          ],
        },
        {
          id: "dolci",
          name: "Dolci",
          items: [
            {
              id: "tiramisu",
              name: "Tiramisu",
              description: "Espresso, mascarpone, cocoa",
              price: usd(900),
              available: true,
            },
            {
              id: "panna-cotta",
              name: "Panna cotta",
              description: "Vanilla cream with berry compote",
              price: usd(800),
              available: true,
            },
            {
              id: "cannoli",
              name: "Cannoli",
              description: "Ricotta, pistachio, orange zest",
              price: usd(750),
              available: true,
            },
            {
              id: "affogato",
              name: "Affogato",
              description: "Vanilla gelato drowned in espresso",
              price: usd(650),
              available: true,
            },
          ],
        },
      ],
    },
    {
      restaurantId: "green-bowl",
      currency: "USD",
      categories: [
        {
          id: "salads",
          name: "Salads",
          items: [
            {
              id: "caesar",
              name: "Caesar",
              description: "Romaine, parmesan, croutons, caesar dressing",
              price: usd(1150),
              available: true,
            },
            {
              id: "greek",
              name: "Greek",
              description: "Cucumber, tomato, feta, olives, oregano",
              price: usd(1200),
              available: true,
            },
            {
              id: "harvest",
              name: "Harvest",
              description: "Kale, roasted squash, apple, pecans",
              price: usd(1300),
              available: true,
            },
            {
              id: "cobb",
              name: "Cobb",
              description: "Chicken, bacon, egg, avocado, blue cheese",
              price: usd(1450),
              available: true,
            },
          ],
        },
        {
          id: "drinks",
          name: "Drinks",
          items: [
            {
              id: "lemonade",
              name: "Mint lemonade",
              description: "Fresh lemon and mint",
              price: usd(450),
              available: true,
            },
            {
              id: "iced-tea",
              name: "Iced green tea",
              description: "Unsweetened",
              price: usd(375),
              available: true,
            },
            {
              id: "kombucha",
              name: "Ginger kombucha",
              description: "Locally brewed",
              price: usd(550),
              available: true,
            },
            {
              id: "sparkling-water",
              name: "Sparkling water",
              description: "Still or sparkling",
              price: usd(300),
              available: true,
            },
          ],
        },
      ],
    },
  ],
};
