import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';
import { Level } from 'level';

export interface FileMetadata {
  ownerId: string;
  expirationDate: Date;
  // Size in bytes. Might be needed if we want to restore the data from Fr[]. For now, files are stored as is.
  size: number;
}

export class FileStorage {
  private clusterSize: number;
  private fileDirectory: string;
  // private reservedFiles: Level<string, Date>;

  constructor(clusterSize: number = 1024 * 128, fileDirectory: string = './files') {
    this.clusterSize = clusterSize;
    this.fileDirectory = fileDirectory;
    // this.reservedFiles = new Level('reserved-files', { valueEncoding: 'json' });

    if (!fs.existsSync(this.fileDirectory)) {
      fs.mkdirSync(this.fileDirectory, { recursive: true });
    }
  }

  private getFilePath(fileName: string): string {
    return path.join(this.fileDirectory, fileName);
  }

  // TODO: Only supports files that fit into a single cluster for now.
  async reserve(fileName: string, metadata: FileMetadata): Promise<string> {
    let filePath: string;

    // // Check for expired files to reuse
    // for await (const [reservedFileName, reservedFileDate] of this.reservedFiles.iterator()) {
    //   if (reservedFileDate < new Date()) {
    //     fileName = reservedFileName;
    //     filePath = this.getFilePath(fileName);
    //     fs.truncateSync(filePath, 0);
    //     await this.reservedFiles.del(reservedFileName);
    //     await this.reservedFiles.put(fileName, metadata.expirationDate);
    //     return fileName;
    //   }
    // }

    // Create a new file if no expired files are found
    filePath = this.getFilePath(fileName);
    const buffer = Buffer.alloc(this.clusterSize);
    fs.writeFileSync(filePath, buffer);
    fs.writeFileSync(`${filePath}.meta`, JSON.stringify(metadata));
    // await this.reservedFiles.put(fileName, metadata.expirationDate);

    return fileName;
  }

  async write(fileName: string, buffer: Buffer) {
    const filePath = this.getFilePath(fileName);

    if (buffer.length > this.clusterSize) {
      throw new Error('File size exceeds cluster size');
    }

    if (!fs.existsSync(filePath)) {
      throw new Error('File not reserved');
    }

    fs.writeFileSync(filePath, buffer);
  }

  async read(fileName: string): Promise<Buffer | undefined> {
    const filePath = this.getFilePath(fileName);

    if (!fs.existsSync(filePath)) {
      return undefined;
    }

    const data = fs.readFileSync(filePath);
    return data;
  }
}
