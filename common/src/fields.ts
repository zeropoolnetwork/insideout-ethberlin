// import { randomBytes as cryptoRandomBytes } from 'crypto';

// export function randomBytes(len: number) {
//   return new Uint8Array(cryptoRandomBytes(len));
// }

export function uint8ArrayToHexString(uint8Array: Uint8Array) {
  return uint8Array.reduce((accumulator, byte) => accumulator + byte.toString(16).padStart(2, '0'), '');
}

export function toBigIntBE(bytes: Uint8Array) {
  // A Buffer in node, *is* a Uint8Array. We can't refuse it's type.
  // However the algo below only works on an actual Uint8Array, hence we make a new one to be safe.
  bytes = new Uint8Array(bytes);
  let bigint = BigInt(0);
  const view = new DataView(bytes.buffer);
  for (let i = 0; i < bytes.byteLength; i++) {
    bigint = (bigint << BigInt(8)) + BigInt(view.getUint8(i));
  }
  return bigint;
}

export function toBufferBE(value: bigint, byteLength = 32) {
  const bytes = new Uint8Array(byteLength);
  const view = new DataView(bytes.buffer);
  for (let i = 0; i < byteLength; i++) {
    view.setUint8(byteLength - i - 1, Number(value & BigInt(0xff)));
    value >>= BigInt(8);
  }
  return bytes;
}


// TODO(#4189): Replace with implementation in yarn-project/foundation/src/fields/fields.ts
export class Fr {
  static ZERO = new Fr(0n);
  static MODULUS = 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001n;
  static MAX_VALUE = this.MODULUS - 1n;
  static SIZE_IN_BYTES = 32;
  value: Uint8Array;

  constructor(value: Uint8Array | bigint) {
    // We convert buffer value to bigint to be able to check it fits within modulus
    const valueBigInt = typeof value === 'bigint' ? value : toBigIntBE(value);

    if (valueBigInt > Fr.MAX_VALUE) {
      throw new Error(`Fr out of range: ${valueBigInt}`);
    }

    this.value = typeof value === 'bigint' ? toBufferBE(value) : value;
  }

  // static random() {
  //   const r = toBigIntBE(randomBytes(64)) % Fr.MODULUS;
  //   return new this(r);
  // }

  static fromBuffer(buffer: Uint8Array) {
    return new this(buffer.slice(0, this.SIZE_IN_BYTES));
  }

  static fromBufferReduce(buffer: Uint8Array) {
    return new this(toBigIntBE(buffer.slice(0, this.SIZE_IN_BYTES)) % Fr.MODULUS);
  }

  static fromString(str: string) {
    return this.fromBuffer(Buffer.from(str.replace(/^0x/i, ''), 'hex'));
  }

  toBuffer() {
    return this.value;
  }

  toString() {
    return '0x' + uint8ArrayToHexString(this.toBuffer());
  }

  equals(rhs: Fr) {
    return this.value.every((v, i) => v === rhs.value[i]);
  }

  isZero() {
    return this.value.every(v => v === 0);
  }
}

export class Fq {
  static MODULUS = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47n;
  static MAX_VALUE = this.MODULUS - 1n;
  static SIZE_IN_BYTES = 32;

  constructor(public readonly value: bigint) {
    if (value > Fq.MAX_VALUE) {
      throw new Error(`Fq out of range ${value}.`);
    }
  }

  static random() {
    const r = toBigIntBE(randomBytes(64)) % Fq.MODULUS;
    return new this(r);
  }

  static fromBuffer(buffer: Uint8Array) {
    return new this(toBigIntBE(buffer.slice(0, this.SIZE_IN_BYTES)));
  }

  static fromBufferReduce(buffer: Uint8Array) {
    return new this(toBigIntBE(buffer.slice(0, this.SIZE_IN_BYTES)) % Fr.MODULUS);
  }

  static fromString(str: string) {
    return this.fromBuffer(Buffer.from(str.replace(/^0x/i, ''), 'hex'));
  }

  toBuffer() {
    return toBufferBE(this.value, Fq.SIZE_IN_BYTES);
  }

  toString() {
    return '0x' + this.value.toString(16);
  }

  equals(rhs: Fq) {
    return this.value === rhs.value;
  }

  isZero() {
    return this.value === 0n;
  }
}
