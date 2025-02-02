import type {
  task_priority__foundation,
  task_status__foundation,
} from '@prisma/client';
import { copycat, faker } from '@snaplet/copycat';
import type { state_usaEnum, userScalars } from '@snaplet/seed';

export const task_statuses: Partial<task_status__foundation>[] = [
  { id: 0, label: 'Backlog' },
  { id: 1, label: 'Todo' },
  { id: 2, label: 'In Progress' },
  { id: 3, label: 'In Review' },
  { id: 4, label: 'Done' },
  { id: 5, label: 'Cancelled' },
];

export const task_priorities: Partial<task_priority__foundation>[] = [
  { id: 0, label: 'Urgent' },
  { id: 1, label: 'High' },
  { id: 2, label: 'Medium' },
  { id: 3, label: 'Low' },
  { id: 4, label: 'No Priority' },
];

/**
 * This assumes the default roles have been added via migration (i.e. 20241013195745_tenant_foundation)
 */
export const genUserGroups = ({
  underwriters,
  admins,
  borrowers,
  agents,
  orgNumber,
}: {
  admins: userScalars[];
  agents: userScalars[];
  underwriters: userScalars[];
  borrowers: userScalars[];
  orgNumber: number;
}) => ({
  org_admins: copycat
    // Pick some of the users for uat
    .someOf(orgNumber, [admins.length / 2, admins.length], admins)
    .map(u => ({
      user_id: u.clerk_id,
      role_name: 'admin',
    })),
  org_underwriters: copycat
    // Pick some of the users for uat
    .someOf(
      orgNumber,
      [underwriters.length / 2, underwriters.length],
      underwriters
    )
    .map(u => ({
      user_id: u.clerk_id,
      role_name: 'underwriter',
    })),
  org_agents: copycat
    // Pick some of the users for uat
    .someOf(orgNumber, [agents.length / 2, agents.length], agents)
    .map(u => ({
      user_id: u.clerk_id,
      role_name: 'agent',
    })),
  org_borrowers: copycat
    // Pick some of the users for uat
    .someOf(orgNumber, [borrowers.length / 2, borrowers.length], borrowers)
    .map(u => ({
      user_id: u.clerk_id,
      role_name: 'borrower',
    })),
});

export const genUniqueNumeric = (number: number, length: number) => {
  const set = new Set<string>();
  while (set.size < number) {
    set.add(faker.string.numeric(length));
  }
  return Array.from(set);
};

export const genAddress = () => ({
  address: faker.location.streetAddress(),
  address_line_2: faker.location.secondaryAddress(),
  zip: faker.location.zipCode(),
  state: faker.location.state({
    abbreviated: true,
  }) as state_usaEnum,
  city: faker.location.city(),
  county: faker.location.county(),
});
