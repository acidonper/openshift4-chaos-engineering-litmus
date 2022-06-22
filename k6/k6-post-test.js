import { check, sleep } from 'k6';
import { Httpx } from 'https://jslib.k6.io/httpx/0.0.4/index.js';

export const options = {
  httpDebug: 'full',
  insecureSkipTLSVerify: true
};

export const session = new Httpx({
  timeout: 20000
});

export default function testSuite() {

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  const body = {
    'message': 'Hello',
    'last_path': '/jump',
    'jump_path': '/jump',
    'jumps': [
        'http://back-golang-v1:8442',
        'http://back-springboot-v1:8443',
        'http://back-python-v1:8444',
        'http://back-quarkus-v1:8445'
    ],
  };

  const res = session.post(`${__ENV.TEST_URL}`, JSON.stringify(body), JSON.stringify(params));
  check(res, { 'status was 200': (r) => r.status == 200 });
  sleep(1);
}
