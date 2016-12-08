var successes1 = 0, trials1 = 0;
var successes2 = 0, trials2 = 0;
var confidence_level = 0.95;

var accept_msg = "No significant difference";
var reject_msg = "The difference is significant";

function parseCount(str) {
  if (str.match(/^(\d+(?:.\d+))[eE](\d+)$/)) {
    return parseFloat(RegExp.$1) * Math.pow(10, parseInt(RegExp.$2));
  }
  return parseInt(str);
}

function chi_squared_term(e, o) {
  return (e - o) * (e - o) / e;
}

function chi_squared(s1, t1, s2, t2) {
  var test_stat = 0.0;
  var mean_p = (s1 + s2) / (t1 + t2);
  test_stat += chi_squared_term(mean_p * t1, s1);
  test_stat += chi_squared_term((1-mean_p) * t1, t1 - s1);
  test_stat += chi_squared_term(mean_p * t2, s2);
  test_stat += chi_squared_term((1-mean_p) * t2, t2 - s2);
  return test_stat;
}
function confidence_interval(s, t, z_score) {
  var phat = s / t;
  var a = phat + z_score * z_score / (2 * t);
  var b = z_score * Math.sqrt((phat * (1 - phat) + z_score * z_score / (4 * t)) / t);
  var c = (1 + z_score * z_score / t);

  return [ (a - b) / c, (a + b) / c];
}

function valid_values(s, t) {
  return (!isNaN(s) && !isNaN(t) && s >= 0.0 && s <= t);
}

function update_result() {
  var extreme_z_score = ppnd(0.995);
  var z_score = ppnd(1.0-(1.0-confidence_level)/2);
  var extreme_ci1 = confidence_interval(successes1, trials1, extreme_z_score);
  var extreme_ci2 = confidence_interval(successes2, trials2, extreme_z_score);
  var max = Math.max(extreme_ci1[0], extreme_ci1[1], extreme_ci2[0], extreme_ci2[1]);
  var max_pixels = 240;

  var ci1 = confidence_interval(successes1, trials1, z_score);
  var ci2 = confidence_interval(successes2, trials2, z_score);

  if (valid_values(successes1, trials1)) {
    $( "#ci_label1" ).show();
    $( "#lower_ci1" ).width(ci1[0] / max * max_pixels);
    $( "#upper_ci1" ).width((ci1[1] - ci1[0]) / max * max_pixels);

    $( "#lower_ci_value1" ).html(format_number(ci1[0] * 100, 1));
    $( "#upper_ci_value1" ).html(format_number(ci1[1] * 100, 1));
  } else {
    $( "#lower_ci1" ).width(0);
    $( "#upper_ci1" ).width(0);
    $( "#ci_label1" ).hide();
  }

  if (valid_values(successes2, trials2)) {
    $( "#ci_label2" ).show();
    $( "#lower_ci2" ).width(ci2[0] / max * max_pixels);
    $( "#upper_ci2" ).width((ci2[1] - ci2[0]) / max * max_pixels);

    $( "#lower_ci_value2" ).html(format_number(ci2[0] * 100, 1));
    $( "#upper_ci_value2" ).html(format_number(ci2[1] * 100, 1));
  } else {
    $( "#lower_ci2" ).width(0);
    $( "#upper_ci2" ).width(0);
    $( "#ci_label2" ).hide();
  }
  var chi2 = chi_squared(successes1, trials1, successes2, trials2);
  var p_value = isNaN(chi2) ? NaN : 1.0 - jstat.pgamma(chi2, 1 / 2, 1 / 2);
  var p_value_decimals = p_value < 0.05 ? 3 : 2;
  $( "#p_value_operator" ).html(p_value < 0.001 ? "&lt;" : "=");
  $( "#p_value" ).html(p_value < 0.001 ? "0.001" :
      format_number(p_value, p_value_decimals));
  $( "#chi2" ).html(format_number(chi2, 2));

  if (p_value < 1.0 - confidence_level) {
    if (successes1 / trials1 > successes2 / trials2) {
      $( "#verdict_text" ).html("Sample 1 is more successful");
    } else {
      $( "#verdict_text" ).html("Sample 2 is more successful");
    }
    $( "#verdict_text" ).css('color', '#5da100');
  } else {
    $( "#verdict_text" ).css('color', '#f64f01');
    $( "#verdict_text" ).html(accept_msg);
  }
  if (valid_values(successes1, trials1) &&
      valid_values(successes2, trials2)) {
    $( "#verdict" ).show();
  } else {
    $( "#verdict" ).hide();
  }
}

// function update_link() {
//   var hash = "#";
//   if (valid_values(successes1, trials1) &&
//       valid_values(successes2, trials2)) {
//     hash += "!" + successes1 + "/" + trials1 +
//       ";" + successes2 + "/" + trials2 +
//       "@" + Math.round(confidence_level * 100);
//   }
//   $( "#link" ).attr('href', hash);
//   $( "#link_field" ).attr('value', location.href.split("#")[0] + hash);
// }

function update_input() {
  successes1 = parseCount($( "#successes1" ).val());
  successes2 = parseCount($( "#successes2" ).val());
  trials1 = parseCount($( "#trials1" ).val());
  trials2 = parseCount($( "#trials2" ).val());
  update_result();
}

$(function() {
  if (location.hash.match(/^#!(\d+(?:\.\d+[eE]\d+)?)\/(\d+(?:\.\d+[eE]\d+)?);(\d+(?:\.\d+[eE]\d+)?)\/(\d+(?:\.\d+[eE]\d+)?)@(\d+)$/) &&
    valid_values(parseCount(RegExp.$1), parseCount(RegExp.$2)) &&
    valid_values(parseCount(RegExp.$3), parseCount(RegExp.$4)) &&
    parseInt(RegExp.$5) >= 80 && parseInt(RegExp.$5) <= 99
    ) {
    confidence_level = parseInt(RegExp.$5) / 100;
    successes1 = parseCount(RegExp.$1);
    trials1 = parseCount(RegExp.$2);
    successes2 = parseCount(RegExp.$3);
    trials2 = parseCount(RegExp.$4);
  }
  $( "input" ).keyup(function(event) {
    location.hash = "#";
    update_input();
  });

  $( "#successes1" ).val(successes1);
  $( "#successes2" ).val(successes2);
  $( "#trials1" ).val(trials1);
  $( "#trials2" ).val(trials2);
  $( "#confidence_value" ).html(Math.round(confidence_level * 100) + "%");
  update_result();
});
