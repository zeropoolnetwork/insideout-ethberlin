import { Fr } from './fields';

const FIELD_SIZE = Fr.SIZE_IN_BYTES;
const CHUNK_SIZE = Fr.MAX_VALUE.toString(16).length / 2;

export function encodeData(buffer: Uint8Array): Fr[] {
  const elements = [];

  for (let i = 0; i < buffer.length; i += CHUNK_SIZE) {
    const chunk = buffer.subarray(i, i + CHUNK_SIZE);
    const data = new Uint8Array(FIELD_SIZE);
    data.set(chunk, FIELD_SIZE - CHUNK_SIZE);

    const fr = new Fr(chunk);
    elements.push(fr);
  }

  return elements;
}

export function decodeData(elements: Fr[], expectedSize: number): Uint8Array {
  const buffer = new Uint8Array(elements.length * CHUNK_SIZE);

  for (let i = 0; i < elements.length; i++) {
    const element = elements[i];
    const chunk = element.toBuffer().subarray(FIELD_SIZE - CHUNK_SIZE);
    buffer.set(chunk, i * CHUNK_SIZE);
  }

  return buffer.subarray(0, expectedSize);
}
