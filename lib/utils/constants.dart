const String sourceUrl = 'https://my.furwall.net';

const String removeAppBannerJS = '''
(function() {
  var appBanner = document.querySelector('.isApp');
  if (appBanner) {
    appBanner.style.display = 'none';
  }
})();
''';
