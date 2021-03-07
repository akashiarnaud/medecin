# medecin

Cette application est la partie patient du projet

## difficulté
Pas de système de Login, donc pour l'instant on suppose qu'il n'y a que 1 seul patient qui peut prendre rendez vous chez plusieurs médecin (lib/main.dart ligne 300)
```dart
'idPatient': 1,
```

Sur la partie calendrier, on a pas réussi à gerer l'intervalle entre les rendez-vous pour que ça soit toute les heures ou toutes les minutes.
On a utilisé la librairie https://pub.dev/packages/flutter_datetime_picker pour datetimepicker
Pas de gestion des weekeends et des jours fériés non plus, par manque de temps, mais on pouvait faire les différents gestion des dates via la même librairie en utilisant la fonction showDateTimePickerCustom au lieu de showDateTimePickerCustom


