import {
  type Logger as WinstonLogger,
  createLogger,
  format,
  transports,
} from "winston";

export class Logger {
  private logger: WinstonLogger;

  constructor(logger?: WinstonLogger) {
    const winsonFormat = format.combine(
      format.timestamp(),
      format.printf(({ timestamp, level, message, loggerId = "main" }) => {
        return `${timestamp} [${level}] [${loggerId}] ${message}`;
      }),
    );

    this.logger =
      logger ??
      createLogger({
        transports: [
          new transports.Console({
            level: "info",
            format: format.combine(format.colorize(), winsonFormat),
          }),
          new transports.File({
            level: "debug",
            filename: "app.log",
            format: winsonFormat,
            options: { flags: "w" },
          }),
        ],
      });
  }

  child(loggerId: string): Logger {
    const childLogger = this.logger.child({ loggerId });
    return new Logger(childLogger);
  }

  // biome-ignore lint/suspicious/noExplicitAny: <explanation>
  info(...args: any[]): void {
    const message = this.mapMessage(args);
    this.logger.info(message);
  }

  // biome-ignore lint/suspicious/noExplicitAny: <explanation>
  error(...args: any[]): void {
    const message = this.mapMessage(args);
    this.logger.error(message);
  }

  // biome-ignore lint/suspicious/noExplicitAny: <explanation>
  debug(...args: any[]): void {
    const message = this.mapMessage(args);
    this.logger.debug(message);
  }

  // biome-ignore lint/suspicious/noExplicitAny: <explanation>
  private mapMessage(args: any[]): string {
    return args
      .map((arg) =>
        arg instanceof Error
          ? arg.stack
          : typeof arg === "object"
            ? JSON.stringify(arg)
            : String(arg),
      )
      .join(" ");
  }
}

export const logger = new Logger();
