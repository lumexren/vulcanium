# Taslak 01: Vulcanium Branding

> **Durum:** Taslak (Chromium 157 kaynak kodu açıldığında satır numaraları ve kesin context doğrulanacak)

## Hedefler
1. Uygulama görünen adını `Chromium` yerine `Vulcanium` yapmak (`chrome://settings/help`, pencere başlıkları, masaüstü bildirimleri).
2. Profil ve yapılandırma dizinini `~/.config/chromium` yerine `~/.config/vulcanium` olarak ayırmak (sistemdeki mevcut Chromium profiliyle çakışmaması için).
3. `chrome://version` çıktısında `Vulcanium` bilgisini göstermek.
4. Google Chrome ticari marka/ikon dosyalarına dokunmadan `chromium` açık kaynak tema yapısını kullanmak.

## Hedeflenen Dosyalar
* `chrome/app/chromium_strings.grd`
* `components/components_chromium_strings.grd`
* `chrome/common/chrome_paths_linux.cc`
* `chrome/common/chrome_constants.cc`
* `components/version_info/version_info_values.h.version`

## Notlar
* `User-Agent` başlığında web uyumluluğunu bozmamak için `Chrome/<major>.0.0.0` token'ını korumak gerekir; sadece `Vulcanium/<ver>` eklenebilir veya standart Chromium UA bırakılabilir.
