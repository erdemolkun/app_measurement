## App Measurement

This is command line tool to measure various metrics for android applications. All you need is application start activity path. Popular application path can be found [here](packages.md). Current coldboot time and memory usages are measured.

### OS
  * For windows install git-bash. Can be download [here](http://daringfireball.net/projects/markdown/syntax). 

#### SDK

  * Minimum supported android version is Lollipop 5.0 (API : 21) [API Levels] (https://source.android.com/setup/start/build-numbers)

#### Usage

```
./run_apk.sh [-s <com.package.name/activity_name] [-c <count ex : 5>] [2 <sleep duration>]
```

#### Sample command

```
./run_apk.sh -s com.instagram.android/.activity.MainTabActivity -c 5 2
```

#### Demo Outputs

```
PACKAGE   : com.whatsapp
VERSION   : 2.19.203
DEVICE    : HUAWEI LYA-L09
Average Memory Usage :  68036
Average Boot Duration :  344 ms
Success Ratio :  5/5

PACKAGE   : com.google.android.keep
VERSION   : 5.19.291.01.40
DEVICE    : HUAWEI LYA-L09
Average Memory Usage :  60463
Average Boot Duration :  398 ms
Success Ratio :  5/5

PACKAGE   : com.evernote
VERSION   : 8.11
DEVICE    : HUAWEI LYA-L09
Average Memory Usage :  91903
Average Boot Duration :  340 ms
Success Ratio :  5/5

PACKAGE   : com.instagram.android
VERSION   : 105.0.0.18.119
DEVICE    : HUAWEI LYA-L09
Average Memory Usage :  106340
Average Boot Duration :  536 ms
Success Ratio :  5/5
```

