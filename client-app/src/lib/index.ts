// place files you want to import through the `$lib` alias in this folder.
import { encodeData, decodeData } from 'zpst-common';

export function test() {
  let data = encodeData(new TextEncoder().encode('hello world'));
  console.log(data);
}
