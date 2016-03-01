import task from './lib/task';
import fs from 'vinyl-fs';
import ftp from 'vinyl-ftp';

/**
 * Deploy files to FTP server
 */
export default task('deploy', () => {

  if (process.env.TRAVIS_SECURE_ENV_VARS !== 'true') {
    console.log('Skipping deploy. Secure environment variables missing.');
    return;
  }

  if (process.env.TRAVIS_PULL_REQUEST !== 'false') {
    console.log('Skipping deploy. Disabled for pull requests.');
    return;
  }

  if (!process.env.TRAVIS_TAG && process.env.TRAVIS_BRANCH !== 'master') {
    console.log('Skipping deploy. Only master branch deploys.');
    return;
  }

  const path = process.env.TRAVIS_TAG ? '/release' : '/beta';
  const connection = ftp.create({
    host: process.env.FTP_HOST,
    user: process.env.FTP_USER,
    password: process.env.FTP_PASS,
    parallel: 5,
    log: console.log
  });

  return fs.src(['./build/**'], {buffer: false} )
    .pipe(connection.dest(path));
});