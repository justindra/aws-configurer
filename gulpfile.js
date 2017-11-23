var gulp = require('gulp');
var jeditor = require('gulp-json-editor');
var argv = require('yargs').argv;

gulp.task('generate-config', () => {
  return gulp.src('./cloudfront-config.json')
    .pipe(jeditor(function(json) {
      var id = argv.id || argv.domain;
      var domain = argv.domain;
      var certificateArn = argv.certificate;
      var cnames = [
        argv.cname
      ];
      if (!id || !domain || !certificateArn || !cnames.length) {
        console.error('Missing some parameters');
        return new Error('Missing some parameters');
      }
      json.Origins.Items[0].Id = id;
      json.Origins.Items[0].DomainName = domain;
      json.DefaultCacheBehavior.TargetOriginId = id;
      json.ViewerCertificate.ACMCertificateArn = certificateArn;
      json.ViewerCertificate.Certificate = certificateArn;
      json.ViewerCertificate.CertificateSource = 'acm';
      json.Aliases.Items = cnames;
      json.Aliases.Quantity = cnames.length;
      json.CallerReference = Math.floor(Math.random() * 1000 * 1000).toString();
      return json;
    }))
    .pipe(gulp.dest('./config'));
});