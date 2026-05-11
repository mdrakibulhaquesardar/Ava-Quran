const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const data = await prisma.feedHistory.groupBy({
    by: ['ayahKey'],
    where: { interactionType: { in: ['loved', 'saved', 'reflected'] } },
    _count: { ayahKey: true },
  });
  console.log(JSON.stringify(data, null, 2));
  process.exit(0);
}
main();
