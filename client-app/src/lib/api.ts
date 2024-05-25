import { PUBLIC_ROLLUP_API_URL, PUBLIC_NODE_API_URL } from '$env/static/public';

export const ROLLUP_API_URL = PUBLIC_ROLLUP_API_URL || 'http://localhost:3000';
export const NODE_API_URL = PUBLIC_NODE_API_URL || 'http://localhost:3001';

interface FileMetadata {
  ownerId: string;
  size: number;
}

export async function uploadFile(file: File, ownerId: string): Promise<string> {
  const data = await file.arrayBuffer();
  const dataBase64 = btoa(String.fromCharCode(...new Uint8Array(data)));
  const response = await fetch('http://localhost:3000/files', {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ data: dataBase64, metadata: { ownerId, size: data.byteLength } })
  });

  const json = await response.json();
  return json.id;
}

export async function mint(accountId: string, amount: number) {
  const response = await fetch(`${ROLLUP_API_URL}/accounts/${accountId}/mint`, {
    method: 'POST',
    body: JSON.stringify({ amount }),
    headers: {
      'Content-Type': 'application/json',
    },
  });

  return response.json();
}

export type AccountState = {
  id: string;
  balance: number;
  files: string[];
};

export async function getAccount(accountId: string): Promise<AccountState> {
  const response = await fetch(`${ROLLUP_API_URL}/accounts/${accountId}`);
  return response.json();
}

export async function checkStatus(): Promise<{ rollup: boolean, node: boolean }> {
  let rollup = false;
  try {
    const rollupRes = await fetch(`${ROLLUP_API_URL}/status`);
    rollup = rollupRes.ok && (await rollupRes.json()).status === 'OK';
  } catch (err) { }

  let node = false;
  try {
    const nodeRes = await fetch(`${NODE_API_URL}/status`);
    node = nodeRes.ok && (await nodeRes.json()).status === 'OK';
  } catch (err) { }

  return { rollup, node };
}
