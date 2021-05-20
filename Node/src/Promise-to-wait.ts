
/* (1) */

const hello_world_t = (callback: (text: string) => void) => {
  setTimeout(() => {
    callback('Hello');
    setTimeout(() => {
      callback('. . . and welcome');
      setTimeout(() => {
        callback('. . . to asynchronicity in TypeScript!');
      }, 1000);
    }, 1000);
  }, 1000);
};

hello_world_t(text => console.log('1>', text));


/* (2) */

const waitP = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

const hello_world_a = async (callback: (text: string) => void) => {
  await waitP(1000);
  callback('Hello');
  await waitP(1000);
  callback('. . . and welcome');
  await waitP(1000);
  callback('. . . to asynchronicity in TypeScript!');
};

hello_world_a(text => console.log('2>', text));


