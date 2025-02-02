// eslint-disable-next-line @eslint-community/eslint-comments/disable-enable-pair
/* eslint-disable sonarjs/no-nested-functions */
import { createSeedClient, type schemaEnum } from '@snaplet/seed';
import { copycat, faker } from '@snaplet/copycat';

import {
  genAddress,
  genUniqueNumeric,
  genUserGroups,
  task_priorities,
  task_statuses,
} from './utils';

faker.seed(0);

// eslint-disable-next-line @typescript-eslint/no-unused-vars
const range = (n: number) => Array.from({ length: n }, (_, index) => index);

// Env is synonomous with schema
const environments: schemaEnum[] = ['foundation'];

const deal_states = [
  'Submission',
  'Failed Pre Qualification',
  'Submission Validation',
  'Pre Qualified',
  'Pricing',
  'Pricing Validation',
  'Underwriting',
  'Final Underwriting Approval',
  'Contract Out',
  'Contract In',
  'Pre Funding',
  'Funded',
  'Archived',
  'Completed',
];

const scale = 50;

async function main() {
  const seed = await createSeedClient();
  const bussinessCount = scale;
  // Truncate all tables in the database
  await seed.$resetDatabase();

  const dbas = Array.from(genUniqueNumeric(bussinessCount, 6));
  const duns = Array.from(genUniqueNumeric(bussinessCount, 9));
  const tins = Array.from(genUniqueNumeric(bussinessCount, 9));

  const { business: businesses } = await seed.business(x =>
    x(bussinessCount, {
      business_type: faker.company.buzzNoun(),
      date_business_began: new Date(faker.date.birthdate()),
      dba: () => `DBA_${dbas.pop()}`,
      debt: faker.number.int({
        max: 10_000_000,
        min: 100_000,
      }),
      duns: () => duns.pop()!,
      email: faker.internet.email(),
      industry: faker.commerce.department(),
      name_display: faker.company.name(),
      name_legal: faker.company.name(),
      phone: faker.phone.number(),
      revenue_average: faker.number.int({
        max: 10_000_000,
        min: 100_000,
      }),
      tin: () => tins.pop()!,
    })
  );

  await seed.role(
    environments.flatMap(schema => [
      { name: 'admin', schema },
      { name: 'underwriter', schema },
      { name: 'agent', schema },
      { name: 'auditor', schema },
      { name: 'borrower', schema },
    ])
  );

  const { user: borrowers } = await seed.user(x =>
    x(scale, {
      email: context => copycat.email(context.seed),
      date_of_birth: faker.date.birthdate(),
      credit_score: context =>
        copycat.int(context.seed, {
          max: 820,
          min: 380,
        }),
      name: context => copycat.fullName(context.seed),
      phone: context => copycat.phoneNumber(context.seed),
      ssn: faker.string.numeric(9),
      ...genAddress,
      clerk_id: context => copycat.uuid(context.seed),
    })
  );

  const { user: agents } = await seed.user(x =>
    x(scale, {
      email: context => copycat.email(context.seed),
      date_of_birth: faker.date.birthdate(),
      credit_score: context =>
        copycat.int(context.seed, {
          max: 820,
          min: 380,
        }),
      name: context => copycat.fullName(context.seed),
      phone: context => copycat.phoneNumber(context.seed),
      ssn: faker.string.numeric(9),
      ...genAddress,
      clerk_id: context => copycat.uuid(context.seed),
    })
  );

  const { user: admins } = await seed.user(x => [
    ...x(50, {
      email: context => copycat.email(context.seed),
      date_of_birth: faker.date.birthdate(),
      credit_score: context =>
        copycat.int(context.seed, {
          max: 820,
          min: 380,
        }),
      name: context => copycat.fullName(context.seed),
      phone: context => copycat.phoneNumber(context.seed),
      ssn: faker.string.numeric(9),
      ...genAddress,
      clerk_id: context => copycat.uuid(context.seed),
    }),
    {
      email: context => copycat.email(context.seed),
      date_of_birth: faker.date.birthdate(),
      credit_score: context =>
        copycat.int(context.seed, {
          max: 820,
          min: 380,
        }),
      name: 'Zach',
      phone: context => copycat.phoneNumber(context.seed),
      ssn: faker.string.numeric(9),
      ...genAddress,
      clerk_id: 'user_2loU8MkjCrmULtpAZvbXj9QExWr',
    },
  ]);

  const { user: underwriters } = await seed.user(x =>
    x(scale, {
      email: context => copycat.email(context.seed),
      date_of_birth: faker.date.birthdate(),
      credit_score: context =>
        copycat.int(context.seed, {
          max: 820,
          min: 380,
        }),
      name: context => copycat.fullName(context.seed),
      phone: context => copycat.phoneNumber(context.seed),
      ssn: faker.string.numeric(9),
      ...genAddress,
      clerk_id: context => copycat.uuid(context.seed),
    })
  );

  // Do common stuff we can abstract for each org
  for (const [orgNumber, environment] of environments.entries()) {
    const { org_admins, org_agents, org_borrowers, org_underwriters } =
      genUserGroups({
        underwriters,
        borrowers,
        agents,
        admins,
        orgNumber,
      });

    const environment_user = [
      ...org_underwriters,
      ...org_agents,
      ...org_admins,
      ...org_borrowers,
    ];

    const org_businesses = copycat
      // Pick some of the users for uat
      .someOf(orgNumber, [businesses.length / 2, businesses.length], businesses)
      .map(b => ({
        id: b.id,
      }));

    await seed.organization(x =>
      x(1, {
        clerk_id: 'org_2ko38RckCbvGDqbOE3WO4XXpjKP',
        name: environment,
        environment: x =>
          x(1, {
            schema: environment,
            tenant: environment,
          }),
      })
    );

    await seed.task_status(task_statuses);

    await seed.task_priority(task_priorities);

    // Do more complex stuff per env for now
    // TODO: maybe figure out how to loop this but its also useful to create differences in orgs
    // eslint-disable-next-line sonarjs/no-small-switch
    switch (environment) {
      // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition
      case 'foundation': {
        await seed.environment_user(
          environment_user.map(user => ({
            ...user,
            schema: 'foundation',
          }))
        );
        const opportunityIds: string[] = [];
        const { deal_state } = await seed.deal_state(
          deal_states.map((state, index) => ({
            label: state,
            order: index,
          }))
        );
        // This is effectively seeding "active" deals as opportunity is created as a child
        await seed.deal(x =>
          x(scale, ({ seed }) => {
            const dealId = copycat.uuid(seed);
            return {
              id: dealId,
              opportunity: ({ seed }) => {
                const opportunityId = copycat.uuid(seed);
                opportunityIds.push(opportunityId);
                return {
                  id: opportunityId,
                  active_deal_id: dealId,
                  assignee_id: copycat.oneOf(seed, environment_user).user_id,
                  created_by_id: copycat.oneOf(seed, environment_user).user_id,
                  borrower_user_id: copycat.oneOf(seed, org_borrowers).user_id,
                  agent_id: copycat.oneOf(seed, org_agents).user_id,
                  borrower_business_id: copycat.int(seed, {
                    min: 0,
                    max: 1,
                  })
                    ? copycat.oneOf(seed, org_businesses).id
                    : null,
                  label: context =>
                    copycat.int(context.seed, {
                      min: 0,
                      max: 1,
                    })
                      ? copycat.words(context.seed, { min: 1, max: 3 })
                      : null,
                };
              },
              deal_event: x =>
                x({ min: Math.floor(scale / 2), max: scale }, ({ seed }) => ({
                  created_by: copycat.oneOf(seed, [
                    ...org_underwriters,
                    ...org_agents,
                  ]).user_id,
                })),
              assignee_id: faker.helpers.arrayElement(environment_user).user_id,
              created_by_id:
                faker.helpers.arrayElement(environment_user).user_id,
              appetite: faker.number.int({
                max: 100,
                min: 0,
              }),
              task: x =>
                x({ min: 0, max: 10 }, ({ seed }) => ({
                  assignee_id: copycat.oneOf(seed, [
                    ...org_underwriters,
                    ...org_agents,
                  ]).user_id,
                  created_by_id: copycat.oneOf(seed, [
                    ...org_underwriters,
                    ...org_agents,
                  ]).user_id,
                  priority_id: copycat.int(seed, {
                    min: 0,
                    max: task_priorities.length - 1,
                  }),
                  status_id: copycat.int(seed, {
                    min: 0,
                    max: task_statuses.length - 1,
                  }),
                })),
              property: x =>
                x({ min: 1, max: 3 }, ({ seed }) => ({
                  tags: copycat.words(seed, { min: 1, max: 5 }).split(' '),
                  ...genAddress,
                })),
              deal_user: copycat.someOf(
                seed,
                [0, org_underwriters.length],
                org_underwriters
              ),
              interest_rate: Number.parseFloat(
                faker.number
                  .float({
                    fractionDigits: 6,
                    max: 0.07,
                    min: 0.035,
                  })
                  .toFixed(4)
              ),
              loan_amount: Number.parseFloat(
                faker.number
                  .float({
                    max: 10_000_000,
                    min: 100_000,
                  })
                  .toFixed(2)
              ),
              loan_processing_fee: Number.parseFloat(
                faker.number
                  .float({
                    fractionDigits: 2,
                    max: 3000,
                    min: 15,
                  })
                  .toFixed(2)
              ),
              source: faker.lorem.word(),
              ssbs_score: faker.number.int({
                max: 1000,
                min: 500,
              }),
              deal_state_id: copycat.oneOf(seed, deal_state).id,
              winnability: copycat.int(seed, {
                max: 100,
                min: 0,
              }),
            };
          })
        );
        // Insert more deal versions for opportuinities
        for (const opportunity_id of opportunityIds) {
          await seed.deal(x =>
            x({ min: 0, max: 4 }, ({ seed }) => ({
              opportunity_id,
              task: x =>
                x({ min: 0, max: 10 }, ({ seed }) => ({
                  assignee_id: copycat.oneOf(seed, [
                    ...org_underwriters,
                    ...org_agents,
                  ]).user_id,
                  created_by_id: copycat.oneOf(seed, [
                    ...org_underwriters,
                    ...org_agents,
                  ]).user_id,
                  priority_id: copycat.int(seed, {
                    min: 0,
                    max: task_priorities.length - 1,
                  }),
                  status_id: copycat.int(seed, {
                    min: 0,
                    max: task_statuses.length - 1,
                  }),
                })),
              property: x =>
                x({ min: 1, max: 3 }, ({ seed }) => ({
                  tags: copycat.words(seed, { min: 1, max: 5 }).split(' '),
                  ...genAddress,
                })),
              deal_user: () => copycat.someOf(seed, [0, 10], org_underwriters),
              interest_rate: Number.parseFloat(
                faker.number
                  .float({
                    fractionDigits: 6,
                    max: 0.07,
                    min: 0.035,
                  })
                  .toFixed(4)
              ),
              loan_amount: Number.parseFloat(
                faker.number
                  .float({
                    max: 10_000_000,
                    min: 100_000,
                  })
                  .toFixed(2)
              ),
              loan_processing_fee: Number.parseFloat(
                faker.number
                  .float({
                    fractionDigits: 2,
                    max: 3000,
                    min: 15,
                  })
                  .toFixed(2)
              ),
              source: faker.lorem.word(),
              ssbs_score: faker.number.int({
                max: 1000,
                min: 500,
              }),
              created_by_id:
                faker.helpers.arrayElement(environment_user).user_id,
              assignee_id: faker.helpers.arrayElement(org_underwriters).user_id,
              deal_state_id: copycat.oneOf(seed, deal_state).id,
              winnability: copycat.int(seed, {
                max: 100,
                min: 0,
              }),
            }))
          );
        }
        break;
      }
    }
  }
}

main()
  .then(() => {
    // eslint-disable-next-line unicorn/no-process-exit
    process.exit();
  })
  .catch((error: unknown) => {
    console.error(error);
    // eslint-disable-next-line unicorn/no-process-exit
    process.exit(1);
  });
