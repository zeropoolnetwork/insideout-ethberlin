export const ROLLUP_API_URL = 'http://localhost:3000';
export const NODE_API_URL = 'http://localhost:3001';

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

export async function getAccount(accountId: string) {
  const response = await fetch(`${ROLLUP_API_URL}/accounts/${accountId}`);
  return response.json();
}
