# Uzayda Element Avı (iOS / SwiftUI)

5. sınıfa yönelik, kapı kapı bulmaca çözerek ilerleyen, dikey kaydırmalı bir uzay
kaçış oyunu. JSX prototipinden tam SwiftUI projesine taşındı.

## Açma

1. `UzaydaElementAvi/` klasörünü Xcode'a sürükle (ya da
   `UzaydaElementAvi.xcodeproj`'u çift tıkla).
2. Üstte bir iPhone simülatörü seç (iPhone 15 önerilir, iOS 16+ gerekir).
3. **Run** (⌘R).

## Yapı

```
UzaydaElementAvi/
├── UzaydaElementAvi.xcodeproj/
└── UzaydaElementAvi/
    ├── UzaydaElementAviApp.swift   App entry
    ├── ContentView.swift           Screen router
    ├── Models/
    │   ├── Palette.swift           4 renk paleti + Color hex yardımcıları
    │   ├── Tweaks.swift            Hız, glow, ipucu, palet ayarları
    │   ├── World.swift             Dünya üretimi, çarpışma, sabitler
    │   ├── Puzzle.swift            6 tip bulmaca üreteci
    │   ├── GameViewModel.swift     Tek doğruluk kaynağı, persistence
    │   └── GameRuntime.swift       Aktif oyunun çalışan state'i
    └── Views/
        ├── Shared.swift            NeonButton, AmbientBackground, font yardımcıları
        ├── AlienKidView.swift      Astronot karakter (Canvas)
        ├── MainMenuView.swift
        ├── LevelSelectView.swift
        ├── PuzzleView.swift        Soru modali + görsel render
        ├── VictoryView.swift
        ├── GameOverView.swift
        ├── PauseView.swift
        ├── CharacterView.swift
        └── GameplayView.swift      Oyun döngüsü, CADisplayLink, drag, çizimler
```

## Oynanış

- Parmağını sağa/sola kaydırarak astronotu yönlendir.
- Lazer bariyerlerden gediklerden geç, blokları yana eğil ve **element atomlarını** (yeşil küre) topla.
- Her seviyede **3 kapı** var. Her kapıda 5. sınıf bir bulmaca:
  kesir, element formülü, çarpma/bölme, geometri, örüntü, birim çevirme.
- 3 can. Çarpışma veya yanlış cevap → −1.
- Son kapı çözüldükten sonra zafer ekranı; toplam puana göre yıldız.

## Hangi platformlar

- iOS 16+ (iPhone)
- SwiftUI saf; harici bağımlılık yok.

## Notlar / yapım kararları

- Görsel motor saf SwiftUI ile (`Canvas`, gradient, blur). UIKit yalnızca
  `CADisplayLink` için.
- Oyun durumu `GameRuntime` (ObservableObject) içinde tutulur; ekran
  yönlendirmesi ve persistence `GameViewModel` üzerinden.
- `@AppStorage` ile açılan seviye, toplam puan ve kostüm kalıcı.
- Bulmaca süresi, palet, hız vb. ayarları `Tweaks` üzerinden ileride bir ayar
  ekranına bağlanabilir.

## Geliştirme fikirleri

- Haptic geri bildirim (`UIImpactFeedbackGenerator`)
- Ses efektleri (`AVAudioPlayer`)
- iCloud ile kostüm senkronu
- iPad için adaptif layout
