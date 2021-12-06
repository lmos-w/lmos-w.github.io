<!DOCTYPE html>
<html lang="{{ config.language }}">
<head>
  {{ partial('_partials/head/head.swig', {}, {cache: theme.cache.enable}) }}
  {% include '_partials/head/head-unique.swig' %}
  {{- next_inject('head') }}
  <title>{% block title %}{% endblock %}</title>
  {{ partial('_third-party/analytics/index.swig', {}, {cache: theme.cache.enable}) }}
  {{ partial('_scripts/noscript.swig', {}, {cache: theme.cache.enable}) }}
</head>

<body itemscope itemtype="http://schema.org/WebPage">
  <div class="container{%- if theme.motion.enable %} use-motion{%- endif %}">
    <div class="headband"></div>

    <header class="header" itemscope itemtype="http://schema.org/WPHeader">
      <div class="header-inner">{% include '_partials/header/index.swig' %}</div>
    </header>

    {{ partial('_partials/widgets.swig', {}, {cache: theme.cache.enable}) }}

    <main class="main">
      <div class="main-inner">
        <div class="content-wrap">
          {% include '_partials/header/sub-menu.swig' %}
          <div class="content">
            {% block content %}{% endblock %}
          </div>
          {% include '_partials/comments.swig' %}
        </div>
        {%- if theme.sidebar.display !== 'remove' %}
          {% block sidebar %}{% endblock %}
        {%- endif %}
      </div>
    </main>

    <footer class="footer">
      <div class="footer-inner">
        {{ partial('_partials/footer.swig', {}, {cache: theme.cache.enable}) }}
        {{ partial('_third-party/statistics/index.swig', {}, {cache: theme.cache.enable}) }}
        {% block footer %}{% endblock %}
      </div>
    </footer>
  </div>

  {{ partial('_scripts/index.swig', {}, {cache: theme.cache.enable}) }}
  {{ partial('_third-party/index.swig', {}, {cache: theme.cache.enable}) }}

  {%- if theme.pjax %}
    <div id="pjax">
  {%- endif %}

  {% include '_third-party/math/index.swig' %}
  {% include '_third-party/quicklink.swig' %}

  {{- next_inject('bodyEnd') }}

  {%- if theme.pjax %}
    </div>
  {%- endif %}
</body>
{% if theme.baidu_push %}
<script>
(function(){
    var bp = document.createElement('script');
    var curProtocol = window.location.protocol.split(':')[0];
    if (curProtocol === 'https') {
        bp.src = 'https://zz.bdstatic.com/linksubmit/push.js';
    }
    else {
        bp.src = 'http://push.zhanzhang.baidu.com/push.js';
    }
    var s = document.getElementsByTagName("script")[0];
    s.parentNode.insertBefore(bp, s);
})();
</script>
{% endif %}
</html>
