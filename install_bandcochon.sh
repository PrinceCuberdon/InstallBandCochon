#!/bin/sh
#
# Installation de bandcochon
#

# 
# Display a well formated string
#
display_message() {
    echo "\033[1m$1\033[0m"
}

#
# Display the script usage
#
usage() {
    echo "Usage:"
    echo "    install_bandcochon dest_dir source_dir"
    echo "        source_dir is optionnal"
    display_error "$1"
    exit 1
}

# 
# Display a message colored in red
#
display_error() {
    echo "\033[1m\033[31mError: $1\033[0m"
}

# 
# Test argument count
#
if [ $# -lt 1 ]
then
    usage "Missing parameters"
fi

#
# Test if first argument is a directory and it exists
#
# if [ -d $1 ]
# then
#     display_error "The destination directory exists. I can't do the job."
#     exit 1
# fi
# 
# #
# # Test the second arg if exists
# #
# if [ $# -eq 2 ]
# then
#     if [ ! -d $2 ]
#     then
#         display_error "$2 is not a existing directory. I can't do the job."
#         exit 1
#     fi
# fi
# 
echo "\n\n#######################################################################"
echo "#                                                                     #"
echo "#                    BANDCOCHON INSTALLER                             #"
echo "#                                                                     #"
echo "#######################################################################\n"
echo "Hello, this is an automatic installer. Press enter to continue."

# read anykey

HERE=`pwd`
WHERE="$HERE/$2"


# Cloning from git hub
display_message "\n\n# Loading core program from github.com ###############################"
git clone https://github.com/PrinceCuberdon/BandCochon.git $1
cd $1

# Install external libs
display_message "\n\n# Install other libs from github.com #################################"
./process_install.py --install

# Copy older media and static files
display_message "\n\n# Remove www.bandcochon.re static files ##############################"
rm -r static

display_message "\n\n# Create static file and site_media directory ########################"
mkdir site_media static
if [ $# -eq 2 ]
then
    echo "Copying static files"
    cp -r $WHERE/static/*     $HERE/$1/static/
    echo "Copying media files"
    cp -r $WHERE/site_media/* $HERE/$1/site_media/

    # Copy manage.py and change it
    cp $WHERE/manage.py . 
    
    LINES_TO_APPEND="import imp, sys, os\n\n\
this_path = os.path.dirname(os.path.abspath(__file__))\n\
sys.path.append(os.path.join(this_path, 'libs'))\n\
sys.path.append(os.path.join(this_path, 'core'))\n\
"
    sed "s/import imp/$LINES_TO_APPEND/g" manage.py > temp.py
    mv temp.py manage.py
fi




DB_USER=""
DB_PASSWORD=""
DB_BACKEND=""

echo 
display_message "Admin informations"
printf "The admin email address: "; read ADMIN_EMAIL

echo 
display_message "Database configuration"
# TODO: Control validity
printf "What kind of database backend want you use ? [postgresql_psycopg2', 'mysql', 'sqlite3' or 'oracle] : "; read DB_BACKEND
printf "The database name: "; read DB_NAME

if [ ! $DB_BACKEND = "sqlite3" ]
then
    printf "The database user: "; read DB_USER
    printf "The database password: "; read DB_PASSWORD
    printf "The database server host: [default:'']"; read DB_HOST
    printf "The database server port: [default:'']"; read DB_PORT
fi

echo 
display_message "RSS/ATOM Feed configuration"
printf "RSS/ATOM description: "; read RSS_DESC

echo 
display_message "Site configuration"
printf "The site name: "; read SITE_NAME
printf "How will you call a picture: "; read PICT_NAME
printf "How will you pluralize a picture: "; read PICT_PLURAL
printf "How will you call a picture with capital first: "; read PICT_CAPFIRST
printf "How will you call a picture with capital first and pluralized: "; read PICT_PLURAL_CAPFIRST
printf "How will you use an adjectival picture: "; read PICT_ADJ
printf "How will you call a item (see README.md)? "; read PICT_NAME
echo
display_message "Geolocation"
printf "The default lattitude: "; read DEFAULT_LATTITUDE
printf "The default longitude: "; read DEFAULT_LONGITUDE

# Create private_settings
echo "# -*- coding: UTF-8 -*-
ADMINS = (('Admin', '$ADMIN_EMAIL'),)
SERVER_EMAIL = '$ADMIN_EMAIL'
MANAGERS = ADMINS
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.$DB_BACKEND',
        'NAME': '$DB_NAME',
        'USER': '$DB_USER',
        'PASSWORD': '$DB_PASSWORD',
        'HOST': '$DB_HOST',
        'PORT': '$DB_PORT',
    }
}
# Feedme configuration
class FEEDME_CONFIG:
    Title = '$SITE_NAME'
    Description = u'$RSS_DESC'
    
# Configuration for capatcha
class CAPATCHA_CONFIG:
    Download = 'capatcha'
    temp ='capatcha_temp'
    
# Configuration for the blog
class BLOG_CONFIG:
    Download = 'avatar'                 # Where in MEDIA_ROOT the avatars are downloaded

    class Templates:
        index = 'blog/index.html'
        post = 'blog/post.html'
        
# Configuration for BandCochon app
class BANDCOCHON_CONFIG:
    photo_count = 16    # Max displayed pigsty on the root page
    class Upload:
        ''' Upload pathes '''
        avatar = 'avatar'                   # Users avatars
        temp = 'temp'                       # Temp dir
        images = 'photos/%s'                # Pigsties %s is username
        images_proofs = 'photos/proofs'     # Proofes
        waste = 'wastedeposal'              #
        wall = 'wall'                       # Upload from wall. No matter who did it (see ucomment algorithm)
        
    class Avatar:
        ''' Avatar defaults '''
        default = '/staticfiles/images/default_avatar.png'
        no_image = '/staticfiles/images/no-image.png'
        
    class EmailTemplates:
        ''' Email templates (see notification app) '''
        contact_send = 'contact_send'
        lost_password = 'lost_password'
        account_confirmation = 'account_confirmation'   # Account creation confirmation mail
        account_creation_manually = 'account_confirm_manu'
        account_ask_confirm = 'account_ask_confirm'
        teacher_asking = 'teacher_asking'               # Teacher account createion confirmation mail
        teacher_agreed = 'teacher_agreed'
        county_asking = 'county_asking'
        county_agreed = 'county_agreed'
        proof_accepted = 'proof_accepted'
        proof_rejected = 'proof_rejected'
        proof_submission = 'proof_submission'
        poster_submission = 'poster_submission'
        ask_info_message = 'ask_info_message'
        new_message = 'new_message'
        signal_message = 'signal_message'
        
        user_like = 'like-message'
        user_dislike = 'dislike-message'
        user_comment = 'user_comment_message'
        
class BANDCOCHON_TEMPLATES:
    ''' Templates used in the whole web site '''
    index = 'index.html'                        # Home page
    page = 'cms/page.html'                      # Display a page from CMS
    photo = 'photo.html'                        # Display a particular picture
    photo_by = 'photo_by.html'                  # Display photos for an user
    photo_town = 'photo_town.html'              # Display photos for a township
    photo_cleaned = 'photo_cleaned.html'        # Display photos marked as cleaned for a township
    photos = 'photos.html'                      # Display all pictures taken
    comments = 'comments.html'                  # Display the Wall ('{{ SITE_NAME }} book')
    all_pictures = 'all_towns.html'             # Display township ranking
    all_hunters = 'all_hunters.html'            # Display hunter ranking
    all_cleaned = 'all_cleaned.html'            # Display cleaned township rank
    search = 'search.html'                      # Display search results
    contact = 'contact.html'                    # Display contact page. (send email to web masters)
    
    class Account:
        login =   'account/login.html'          # Login form
        home =    'account/home.html'           # User home
        create =  'account/create.html'         # Create a new account
        success = 'account/email_success.html'  # Account created with succes.
        confirm = 'account/confirmation.html'   # Account confirmation
        forgotten = 'account/forgotten.html'    # The user forgot his password
        reset = 'account/reset.html'            # Reset the password
        
    class Includes:
        photo_rendering = 'inc/photo_rendering.html'
        site_book = 'inc/bcbook/bcbook.html'
                
    class Poll:
        ''' Poll app (todo: make it standalone) '''
        results = 'poll/results.html'
        result = 'poll/result.html'
        comment = 'poll/pollcommentcontent.html'
    

GRAPPELLI_ADMIN_TITLE = '''<img src='/staticfiles/images/favicon.png' style='vertical-align:middle; padding-right: 10px' /> $SITE_NAME'''

# Comment les photos sont appellées
PIGSTY_NAME = '$PICT_NAME'
PIGSTY_NAME_PLURAL = '$PICT_PLURAL'
PIGSTY_NAME_ADJ = u'$PICT_ADJ'
PIGSTY_NAME_CAPFIRST = '$PICT_CAPFIRST'
PIGSTY_NAME_CAPFIRST_PLURAL = '$PICT_PLURAL_CAPFIRST'
PIGSTY_PIGNAME = '$PICT_NAME'

# Positionnnement par défaut
DEFAULT_LATTITUDE = '$DEFAULT_LATTITUDE'
DEFAULT_LONGITUDE = '$DEFAULT_LONGITUDE'
" > $HERE/$1/core/config/private_settings.py

display_message "Your private configuration file was written succesfully"
echo "But you should edit $WHERE/$1/core/config/private_settings.py... In case of :)"

echo
display_message "# Create the keys.py for social networks  ##################################"
touch $HERE/$1/core/config/keys.py

#
# Create the default settings file
#
echo "# -*- coding: UTF-8 -*-
'''
Band Cochon 
(c) Prince Cuberdon 2011 and later <princecuberdon@bandcochon.fr>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''
'''
CAUTION : EVERY DJANGO COMMENTS HAVE BEEN REMOVED
'''

import os

# For nginx
FORCE_SCRIPT_NAME=''

# Few helpers.
#       create empty files:
#               debug to activate debug
#               local to activate developpement static file serving
#               debugdb to activate djanog-debugtoolbar
PROJECT_PATH = os.path.dirname(os.path.abspath(__file__))
DEBUG = os.path.exists(os.path.join(PROJECT_PATH, 'debug'))
IS_LOCAL = os.path.exists(os.path.join(PROJECT_PATH, 'local'))
IS_BETA = os.path.exists(os.path.join(PROJECT_PATH, 'beta'))
IS_TESTING = False
IS_DEBUGGING = os.path.exists(os.path.join(PROJECT_PATH, 'debugdb'))

# Force javascript or other static files to reload on changes
NUMBER_OF_RELOAD = 1
filename = os.path.join(PROJECT_PATH, 'number_of_reload.txt')
if os.path.exists(filename):
    NUMBER_OF_RELOAD = int(open(filename, 'r').read())
else:
    open(filename, 'w').write(str(NUMBER_OF_RELOAD))

try:
  import locale
  if not IS_LOCAL:
        locale.setlocale(locale.LC_ALL, 'fr_FR')
except:
    pass

TEMPLATE_DEBUG = DEBUG
TIME_ZONE = 'Indian/Reunion'
LANGUAGE_CODE = 'fr-FR'
SITE_ID = 1
USE_I18N = True
USE_L10N = True
MEDIA_ROOT = os.path.join(PROJECT_PATH, 'site_media')
MEDIA_URL = '/site_media/'
DEV_STATIC_ROOT = os.path.join(PROJECT_PATH, 'static')
STATIC_ROOT = os.path.join(PROJECT_PATH, 'staticfiles')
STATIC_URL = '/staticfiles/'
#ADMIN_MEDIA_PREFIX = '/staticfiles/admin/' # Uncomment for norma admin
ADMIN_MEDIA_PREFIX = STATIC_URL + 'grappelli/'  # Comment for nomal admin
STATICFILES_DIRS = (
    os.path.join(PROJECT_PATH, 'static'),
    os.path.join(PROJECT_PATH, 'libs', 'whosonline', 'static'),
    os.path.join(PROJECT_PATH, 'core', 'bandcochon', 'static'),
)
STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
)
SECRET_KEY = ''
if IS_LOCAL == False:
    # Activate templates compiler on production server
    TEMPLATE_LOADERS = (
        ('django.template.loaders.cached.Loader', (
            'django.template.loaders.filesystem.Loader',
            'django.template.loaders.app_directories.Loader',
        )),)
else:
    TEMPLATE_LOADERS = (
        'django.template.loaders.filesystem.Loader',
        'django.template.loaders.app_directories.Loader',
        'django.template.loaders.eggs.Loader',
    )
MIDDLEWARE_CLASSES = [
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
]
if not IS_DEBUGGING:
    MIDDLEWARE_CLASSES += [
        'django.middleware.gzip.GZipMiddleware',
    ]
else:
    MIDDLEWARE_CLASSES += [
        'debug_toolbar.middleware.DebugToolbarMiddleware',
    ]
ROOT_URLCONF = 'urls'
TEMPLATE_DIRS = [
    os.path.join(PROJECT_PATH, 'templates'),
    os.path.join(PROJECT_PATH, 'libs', 'ucomment', 'templates'),
    os.path.join(PROJECT_PATH, 'core', 'plugins', 'snailmail', 'templates'),
]
TEMPLATE_CONTEXT_PROCESSORS = (
    'django.contrib.auth.context_processors.auth',
    'django.core.context_processors.debug',
    'django.core.context_processors.i18n',
    'django.core.context_processors.media',
    'django.core.context_processors.static',
    'django.contrib.messages.context_processors.messages',
    'django.core.context_processors.request',
    # Social auth 
    'social_auth.context_processors.social_auth_by_name_backends',
    'social_auth.context_processors.social_auth_backends',
    'social_auth.context_processors.social_auth_by_type_backends',
    # Our own libs
    'bandcochon.processors.site_url',
    'bandcochon.processors.is_local',
    'whosonline.processor.online',
    'bandcochon.processors.for_root_page',
    'bandcochon.processors.mecenes',
    'bandcochon.processors.reloadcount',
)
AUTHENTICATION_BACKENDS = (
    'social_auth.backends.twitter.TwitterBackend',
    'social_auth.backends.facebook.FacebookBackend',
    'social_auth.backends.google.GoogleOAuthBackend',
    'social_auth.backends.yahoo.YahooBackend',
    'social_auth.backends.contrib.linkedin.LinkedinBackend',
    'social_auth.backends.contrib.live.LiveBackend',
    'social_auth.backends.contrib.yahoo.YahooOAuthBackend',
    'social_auth.backends.OpenIDBackend',
    'django.contrib.auth.backends.ModelBackend',
)

from core.config.keys import *
from core.config.private_settings import *
SOCIAL_AUTH_COMPLETE_URL_NAME  = 'socialauth_complete'
SOCIAL_AUTH_ASSOCIATE_URL_NAME = 'socialauth_associate_complete'
SOCIAL_AUTH_LOGIN_REDIRECT_URL = '/mon-compte/connexion/social/'
# Which cache manager should we use ? 
# If debug file is present, use DummyCache
bckend = 'django.core.cache.backends.memcached.MemcachedCache'
if IS_LOCAL == True:
    bckend = 'django.core.cache.backends.dummy.DummyCache'
# Install cache
CACHES = {
    'default': {
        'BACKEND' : bckend,
        'LOCATION': 'localhost:11211',
        #'LOCATION': 'bandcochon_cache',
        'KEY_PREFIX' : 'bandcochon_'
    }
}
# Global cache duration in seconds
OWN_CACHE = 30
INSTALLED_APPS = [
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.sitemaps',
    'django.contrib.humanize',
    #Admin and Grappelli
    'grappelli.dashboard',
    'grappelli',
    'filebrowser',
    'django.contrib.admin',
    'django.contrib.admindocs',
    # Easy evolution utility
    'django_evolution',
    'libs',             # The libs directory contains the command management (see README)
    # Third party Libraries
    'libs.ckeditor',    # Use CKEditor with Grappelli and Filebrowser
    # Own library
    'libs.capatcha',    # SImple captcha lib
    'libs.notification',# Mail communication lib
    'libs.poll',        # Polls (for bandcochon - may be standalone)
    'libs.ucomment',    # Universal comment system
    'libs.feedme',      # Feed Me - Common Feed processor
    'libs.whosonline',  # Real time engine to know who is online (registred user or not)
    # Bandcochon
    'core.bandcochon',
    # Blog
    'libs.blog', # The blog library. Dependencies are: capatcha, notification, ckeditor, ucomment
    # Plugins
    # Snail Mail lobbying
    'core.plugins.snailmail',
    # Fortune for fun (account part)
    'core.plugins.fortune',
    # Social networks connection
    'social_auth',
    # Some utils for templatetags
    'core.common',
]
if IS_DEBUGGING:
    INTERNAL_IPS = ('127.0.0.1',)
    INSTALLED_APPS.append('debug_toolbar')
# Setup GEOIP path
GEOIP_PATH = os.path.join(PROJECT_PATH, 'GeoIP.dat')
GEOS_LIBRARY_PATH = '/usr/lib/libgeos_c.so.1'

# DON'T FORGET TO TRANSLATE THOSE URLS
LOGIN_URL =          '/mon-compte/connexion/'
LOGIN_REDIRECT_URL = '/mon-compte/'

AUTH_PROFILE_MODULE = 'bandcochon.Utilisateur'
# Save the session each time it's called. This for poll.
SESSION_SAVE_EVERY_REQUEST = True
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'mail_admins': {
            'level': 'ERROR',
            'class': 'django.utils.log.AdminEmailHandler'
        }
    },
    'loggers': {
        'django.request': {
            'handlers': ['mail_admins'],
            'level': 'ERROR',
            'propagate': True,
        },
    }
}
MISSING_IMAGE = os.path.join(STATIC_URL, 'images', 'no-image.png')
# CKEditor configuration
CKEDITOR_CONFIGS = {
    'default': {
        'toolbar': [
            [      'Undo', 'Redo',
              '-', 'Bold', 'Italic', 'Underline',
              '-', 'Link', 'Unlink', 'Anchor',
              '-',  'Styles','Format','Font','FontSize',
              '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock',
              '-', 'SpellChecker', 'Scayt',
              '-', 'Maximize',
            ],
            [      'HorizontalRule',
              '-', 'BulletedList', 'NumberedList',
              '-', 'Cut','Copy','Paste','PasteText','PasteFromWord',
              '-', 'SpecialChar',
              '-', 'Source',
            ],
            [
                'Outdent','Indent'
            ],
            [      'Image', 'Flash',
              '-', 'Table', 'HorizontalRule','Smiley','SpecialChar'
            ],
            [ 'About' , ]
        ],
        'width': 1050,
        'height': 600,
        'toolbarCanCollapse': False,
    }
}
CKEDITOR_MEDIA_PREFIX = os.path.join(MEDIA_URL, 'ckeditor')
CKEDITOR_UPLOAD_PATH = os.path.join(MEDIA_ROOT, 'ckeditor')

# Grapelli settings
GRAPPELLI_INDEX_DASHBOARD = 'core.config.dashboard.CustomIndexDashboard'

# UComment configuration
UCOMMENT_CONFIG_TEMPLATE = 'ucomment/message.html'
UCOMMENT_CONFIG_TEMPLATE_RESPONSE  = 'ucomment/submessage.html'

# Create directories (not automatic) Each time ./manage.py run the directory are tested
alldirs = (
    os.path.join(MEDIA_ROOT, BANDCOCHON_CONFIG.Upload.avatar),
    os.path.join(MEDIA_ROOT, BANDCOCHON_CONFIG.Upload.temp),
    os.path.join(MEDIA_ROOT, BANDCOCHON_CONFIG.Upload.waste),
    os.path.join(MEDIA_ROOT, BANDCOCHON_CONFIG.Upload.wall),
    os.path.join(MEDIA_ROOT, CAPATCHA_CONFIG.temp),
    os.path.join(MEDIA_ROOT, CAPATCHA_CONFIG.Download),
    os.path.join(MEDIA_ROOT, BANDCOCHON_CONFIG.Upload.images_proofs, 'proofs'),
)

for directory in alldirs:
    if not os.path.exists(directory):
        os.makedirs(directory)
" > $HERE/$1/settings.py
display_message "# Writing settings.py ######################################################"

echo 
display_message "# Collecting statics #######################################################"
python manage.py collectstatic

# echo 
# display_message "# Evolve the database in case of... ########################################"
# python manage.py evolve --hint -x