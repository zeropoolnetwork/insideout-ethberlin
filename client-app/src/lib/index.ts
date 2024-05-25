// place files you want to import through the `$lib` alias in this folder.
import { encodeData, decodeData } from 'zpst-common';
import { ethers, Wallet, JsonRpcProvider } from 'ethers';
import type { Provider, HDNodeWallet } from 'ethers';

let wallet: HDNodeWallet;
let provider: Provider;

export const TEST_MNEMONIC = 'candy maple cake sugar pudding cream honey rich smooth crumble sweet treat';

export function test() {
  let data = encodeData(new TextEncoder().encode('hello world'));
  console.log(data);
}

export async function initWallet(mnemonic?: string) {
  if (wallet) {
    return;
  }

  if (!mnemonic) {
    if (localStorage.getItem('mnemonic')) {
      mnemonic = localStorage.getItem('mnemonic')!;
    } else {
      throw new Error('Mnemonic is not provided');
    }
  } else {
    localStorage.setItem('mnemonic', mnemonic); // FIXME: encrypt
  }

  provider = new JsonRpcProvider('https://rpc.sepolia.org', 'sepolia');
  wallet = Wallet.fromPhrase(mnemonic).connect(provider);

  console.log('Wallet:', wallet.address);
  console.log('ETH Balance:', await provider.getBalance(wallet.address));
}

export function isWalletInitialized() {
  return !!wallet;
}

export function getAddress() {
  return wallet.address;
}

