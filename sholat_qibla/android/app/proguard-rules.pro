# ProGuard/R8 rules untuk build rilis Miqat.

# flutter_local_notifications memakai Gson untuk (de)serialisasi notifikasi
# terjadwal. Pertahankan kelasnya agar tidak di-strip saat minify.
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Pertahankan tipe generik yang dipakai TypeToken Gson.
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type

# Flutter embedding & plugin (aman default, ditegaskan).
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# geolocator
-keep class com.baseflow.geolocator.** { *; }

# Flutter deferred components (Google Play Core) — tidak dipakai aplikasi ini.
# Abaikan referensi kelasnya agar R8 tidak gagal karena "Missing class".
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
