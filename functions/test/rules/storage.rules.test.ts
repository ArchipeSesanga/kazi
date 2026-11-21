import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteObject, getBytes, ref, uploadBytes } from 'firebase/storage';
import { afterAll, beforeAll, describe, it } from 'vitest';

const owner = 'owner1';
const other = 'other1';
let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'kazi-storage-rules-test',
    storage: { rules: readFileSync(resolve(process.cwd(), '../storage.rules'), 'utf8') },
  });
});
afterAll(async () => testEnv.cleanup());

const storageOf = (id: string, claims: Record<string, unknown> = { phone_number: '+243810000001' }) =>
  testEnv.authenticatedContext(id, claims).storage();
const ownerStorage = () => storageOf(owner);

const bytes = (n: number) => new Uint8Array(n);
const MB = 1024 * 1024;
const jpeg = { contentType: 'image/jpeg' };

const upload = (s: ReturnType<typeof ownerStorage>, path: string, size = 1024, meta: object = jpeg) =>
  uploadBytes(ref(s, path), bytes(size), meta);

describe('media — avatar, cover, portfolio', () => {
  for (const kind of ['avatar', 'cover', 'portfolio']) {
    it(`owner can upload a ${kind} image under 2 MB`, async () => {
      await assertSucceeds(upload(ownerStorage(), `media/${owner}/${kind}/a.jpg`, MB));
    });
  }

  it('accepts png and webp', async () => {
    await assertSucceeds(upload(ownerStorage(), `media/${owner}/avatar/b.png`, 1024, { contentType: 'image/png' }));
    await assertSucceeds(upload(ownerStorage(), `media/${owner}/avatar/c.webp`, 1024, { contentType: 'image/webp' }));
  });

  it('denies another user writing into the owner’s folder', async () => {
    await assertFails(upload(storageOf(other), `media/${owner}/avatar/a.jpg`));
    await assertFails(upload(storageOf(other), `media/${owner}/portfolio/a.jpg`));
  });

  it('denies a PDF and a 3 MB image', async () => {
    await assertFails(upload(ownerStorage(), `media/${owner}/avatar/doc.pdf`, 1024, { contentType: 'application/pdf' }));
    await assertFails(upload(ownerStorage(), `media/${owner}/avatar/big.jpg`, 3 * MB));
  });

  it('denies an upload with no content type', async () => {
    await assertFails(uploadBytes(ref(ownerStorage(), `media/${owner}/avatar/n.jpg`), bytes(1024)));
  });

  it('denies unknown kinds and writes into thumbs/', async () => {
    await assertFails(upload(ownerStorage(), `media/${owner}/misc/a.jpg`));
    await assertFails(upload(ownerStorage(), `media/${owner}/thumbs/a.jpg`));
    await assertFails(upload(ownerStorage(), `media/${owner}/listings/l1/thumbs/a.jpg`));
  });

  it('allows public reads', async () => {
    await assertSucceeds(upload(ownerStorage(), `media/${owner}/avatar/read.jpg`));
    await assertSucceeds(getBytes(ref(testEnv.unauthenticatedContext().storage(), `media/${owner}/avatar/read.jpg`)));
  });

  it('only the owner can delete', async () => {
    await upload(ownerStorage(), `media/${owner}/cover/del.jpg`);
    await assertFails(deleteObject(ref(storageOf(other), `media/${owner}/cover/del.jpg`)));
    await assertSucceeds(deleteObject(ref(ownerStorage(), `media/${owner}/cover/del.jpg`)));
  });
});

describe('media — listing photos', () => {
  it('owner can upload a listing photo under 2 MB', async () => {
    await assertSucceeds(upload(ownerStorage(), `media/${owner}/listings/l1/p1.jpg`, MB));
  });

  it('denies other users, PDFs and oversized photos', async () => {
    await assertFails(upload(storageOf(other), `media/${owner}/listings/l1/p1.jpg`));
    await assertFails(upload(ownerStorage(), `media/${owner}/listings/l1/p2.pdf`, 1024, { contentType: 'application/pdf' }));
    await assertFails(upload(ownerStorage(), `media/${owner}/listings/l1/p3.jpg`, 3 * MB));
  });

  it('only the owner can delete a listing photo', async () => {
    await upload(ownerStorage(), `media/${owner}/listings/l1/del.jpg`);
    await assertFails(deleteObject(ref(storageOf(other), `media/${owner}/listings/l1/del.jpg`)));
    await assertSucceeds(deleteObject(ref(ownerStorage(), `media/${owner}/listings/l1/del.jpg`)));
  });
});

describe('private verification documents', () => {
  const path = `private/verification/${owner}/id.jpg`;

  it('owner can create a document up to 5 MB', async () => {
    await assertSucceeds(upload(ownerStorage(), path, 4 * MB));
  });

  it('denies another user, PDFs and files over 5 MB', async () => {
    await assertFails(upload(storageOf(other), `private/verification/${owner}/x.jpg`));
    await assertFails(upload(ownerStorage(), `private/verification/${owner}/x.pdf`, 1024, { contentType: 'application/pdf' }));
    await assertFails(upload(ownerStorage(), `private/verification/${owner}/big.jpg`, 6 * MB));
  });

  const seed = () =>
    testEnv.withSecurityRulesDisabled(async (ctx) => {
      await uploadBytes(ref(ctx.storage(), path), bytes(1024), jpeg);
    });

  it('nobody can read it, owner included', async () => {
    await seed();
    await assertFails(getBytes(ref(ownerStorage(), path)));
    await assertFails(getBytes(ref(testEnv.unauthenticatedContext().storage(), path)));
  });

  it('the owner cannot overwrite it', async () => {
    await seed();
    await assertFails(upload(ownerStorage(), path, 2048));
  });

  it('a document the owner uploaded cannot be overwritten either', async () => {
    const p = `private/verification/${owner}/own.jpg`;
    await assertSucceeds(upload(ownerStorage(), p, 1024));
    await assertFails(upload(ownerStorage(), p, 2048));
  });

  it('the owner cannot delete it', async () => {
    await seed();
    await assertFails(deleteObject(ref(ownerStorage(), path)));
  });
});

describe('signed-in definition (verified phone or admin claim)', () => {
  it('denies an email-only account uploading to its own folder', async () => {
    await assertSucceeds(upload(storageOf('e1'), `media/e1/avatar/a.jpg`)); // control: phone account
    await assertFails(upload(storageOf('e2', { email: 'dev@example.com' }), `media/e2/avatar/a.jpg`));
    await assertFails(upload(storageOf('e2', { email: 'dev@example.com' }), `private/verification/e2/id.jpg`));
  });

  it('an unauthenticated user cannot upload', async () => {
    await assertFails(uploadBytes(ref(testEnv.unauthenticatedContext().storage(), `media/${owner}/avatar/u.jpg`), bytes(10), jpeg));
  });
});
