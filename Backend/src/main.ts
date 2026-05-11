import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { existsSync, readFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { AppModule } from './app.module';

/** Package root (folder containing `dist/` and `.env`), not `process.cwd()`. */
const packageRoot = join(__dirname, '..');

function parseEnvFile(content: string): Record<string, string> {
  const out: Record<string, string> = {};
  for (const line of content.split('\n')) {
    const t = line.trim();
    if (!t || t.startsWith('#')) continue;
    const eq = t.indexOf('=');
    if (eq === -1) continue;
    const key = t.slice(0, eq).trim();
    let val = t.slice(eq + 1).trim();
    if (
      (val.startsWith('"') && val.endsWith('"')) ||
      (val.startsWith("'") && val.endsWith("'"))
    ) {
      val = val.slice(1, -1);
    }
    out[key] = val;
  }
  return out;
}

/**
 * Read SWAGGER_ENABLED from env files with the same merge order as
 * ConfigModule `envFilePath: ['.env.local', '.env']` (.env.local wins on
 * duplicate keys). This avoids a Nest quirk: variables already present in
 * `process.env` (even empty) are never overwritten from the file, so
 * SWAGGER_ENABLED in .env could be ignored and Swagger would stay off.
 */
function swaggerEnabledFlagFromFiles(): string | undefined {
  const paths = ['.env.local', '.env'].map((f) => resolve(packageRoot, f));
  let merged: Record<string, string> = {};
  for (const p of paths) {
    if (!existsSync(p)) continue;
    merged = { ...parseEnvFile(readFileSync(p, 'utf8')), ...merged };
  }
  const v = merged.SWAGGER_ENABLED;
  return v === undefined ? undefined : v.trim();
}

function shouldEnableSwagger(): boolean {
  const fromFiles = swaggerEnabledFlagFromFiles();
  const flag = (fromFiles ?? process.env.SWAGGER_ENABLED)?.trim();
  if (flag === 'false') return false;
  if (flag === 'true') return true;
  return process.env.NODE_ENV !== 'production';
}

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidUnknownValues: true,
    }),
  );
  const port = Number(process.env.PORT) || 3000;

  if (shouldEnableSwagger()) {
    const swaggerConfig = new DocumentBuilder()
      .setTitle('Ava Quran API')
      .setDescription(
        'NestJS API for personalized Qurʼan feed, reflections, and integrations.',
      )
      .setVersion('1.0')
      .addBearerAuth()
      .build();
    const document = SwaggerModule.createDocument(app, swaggerConfig);
    SwaggerModule.setup('docs', app, document, {
      jsonDocumentUrl: 'docs/json',
    });
  }

  await app.listen(port);
}
void bootstrap();
