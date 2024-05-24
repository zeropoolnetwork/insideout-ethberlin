export interface Account {
  id: string,
  owner: string,
  balance: bigint,
}

export interface DataEntry {
  timestamp: number,
  owner: string,
  hash: string,
}
