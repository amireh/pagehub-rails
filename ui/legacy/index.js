/* global define: false */

window.PHLegacy = {};

define([
  'pagehub.state',
  'pagehub',
  'config',
  'underscore',
  'jquery',
  'jquery.ui',
  'jquery.tinysort',
  'handlebars/runtime',
  'inflection',
  'md5',
  'shortcut',
  'helpers/handlebars',
  'helpers/jquery',
  'backbone',

  'models/folder',
  'models/page',
  'models/space',
  'models/user',
  'collections/folders',
  'collections/pages',
  'collections/spaces',
  'views/flash',
  'views/header',
  'views/shared/animable_view',
  'views/shared/settings/director',
  'views/shared/settings/nav',
  'views/shared/settings/setting_view',
  'views/spaces/show',
  'views/spaces/new',
  'views/spaces/settings/index',
  'views/users/dashboard/director',
  'views/users/settings/index',
  'views/welcome/landing_page',
  'boot',
], function() {
  console.log('PageHubLegacy booted.');
});
