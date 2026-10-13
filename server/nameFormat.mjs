// Mise en forme des identités (demande d'onboarding, compte Microsoft).
//   Prénom : « jean-bernard » -> « Jean-Bernard »
//   Nom    : « dupont »       -> « DUPONT »
//   Poste  : « CHEF DE PROJET » -> « Chef De Projet »

// Majuscule au début de chaque mot. Prénoms : aussi après une apostrophe
// (« O'Neil ») ; postes : non (« Chargé D'affaires » plutôt que « D'Affaires »).
const capitalizeWords = (value, separators = /(^|[\s-])(\p{L})/gu) =>
  String(value ?? '')
    .trim()
    .replace(/\s+/g, ' ')
    .toLocaleLowerCase('fr-FR')
    .replace(separators, (_, separator, letter) => separator + letter.toLocaleUpperCase('fr-FR'));

export const formatFirstName = (value) => capitalizeWords(value, /(^|[\s\-'’])(\p{L})/gu);

export const formatLastName = (value) =>
  String(value ?? '')
    .trim()
    .replace(/\s+/g, ' ')
    .toLocaleUpperCase('fr-FR');

export const formatJobTitle = (value) => capitalizeWords(value);

export const formatDisplayName = (firstName, lastName) =>
  [formatFirstName(firstName), formatLastName(lastName)].filter(Boolean).join(' ');
