export const makeId = (length) => {
  let result = '';

  const characters = 'abcdefhijklmnopqrstuvwxyz0123456789';

  for (let i = 0; i < length; i += 1) {
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }

  return result;
};
