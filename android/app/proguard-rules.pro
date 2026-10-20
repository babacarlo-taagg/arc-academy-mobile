# Règles R8 de l'appli ARC Academy (les extensions Flutter apportent les leurs).
# WorkManager : la tâche de fond est retrouvée par son nom de classe.
-keep class dev.fluttercommunity.workmanager.** { *; }
# Coffre-fort (Keystore) : chiffreurs choisis par réflexion.
-keep class com.it_nomads.fluttersecurestorage.** { *; }
