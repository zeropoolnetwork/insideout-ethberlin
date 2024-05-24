import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';

export interface FileMetadata {
  ownerId: string;
  expirationDate: Date;
}

export class FileStorage {
  private clusterSize: number;
  private fileDirectory: string;
  private reservedFiles: Map<string, Date>;

  constructor(clusterSize: number = 1024 * 128, fileDirectory: string = './files') {
    this.clusterSize = clusterSize;
    this.fileDirectory = fileDirectory;
    this.reservedFiles = new Map();

    if (!fs.existsSync(this.fileDirectory)) {
      fs.mkdirSync(this.fileDirectory, { recursive: true });
    }
  }

  private generateFileName(): string {
    return crypto.randomBytes(16).toString('hex');
  }

  private getFilePath(fileName: string): string {
    return path.join(this.fileDirectory, fileName);
  }

  // TODO: Only supports files that fit into a single cluster for now.
  public reserve(metadata: FileMetadata): string {
    let fileName: string;
    let filePath: string;

    // Check for expired files to reuse
    for (const [reservedFileName, reservedFileDate] of this.reservedFiles) {
      if (reservedFileDate < new Date()) {
        fileName = reservedFileName;
        filePath = this.getFilePath(fileName);
        fs.truncateSync(filePath, 0);
        this.reservedFiles.delete(reservedFileName);
        this.reservedFiles.set(fileName, metadata.expirationDate);
        return fileName;
      }
    }

    // Create a new file if no expired files are found
    fileName = this.generateFileName();
    filePath = this.getFilePath(fileName);
    const buffer = Buffer.alloc(this.clusterSize);
    fs.writeFileSync(filePath, buffer);
    this.reservedFiles.set(fileName, metadata.expirationDate);
    return fileName;
  }

  public write(fileName: string, buffer: Buffer): void {
    const filePath = this.getFilePath(fileName);

    if (!this.reservedFiles.has(fileName)) {
      throw new Error('File not reserved or expired.');
    }

    fs.writeFileSync(filePath, buffer);
  }
}
