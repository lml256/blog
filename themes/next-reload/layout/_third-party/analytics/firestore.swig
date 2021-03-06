{%- if theme.firestore.enable %}
  <script src="https://www.gstatic.com/firebasejs/6.3.3/firebase-app.js"></script>
  <script src="https://www.gstatic.com/firebasejs/6.3.3/firebase-firestore.js"></script>
  {%- if theme.firestore.bluebird %}
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bluebird/3.5.1/bluebird.core.min.js"></script>
  {%- endif %}
  <script{{ pjax }}>
  (function() {

    firebase.initializeApp({
      apiKey: '{{ theme.firestore.apiKey }}',
      projectId: '{{ theme.firestore.projectId }}'
    });

    function getCount(doc, increaseCount) {
      //increaseCount will be false when not in article page

      return doc.get().then(d => {
        var count;
        if (!d.exists) { //has no data, initialize count
          if (increaseCount) {
            doc.set({
              count: 1
            });
            count = 1;
          } else {
            count = 0;
          }
        } else { //has data
          count = d.data().count;
          if (increaseCount) {
            if (!(window.localStorage && window.localStorage.getItem(title))) { //if first view this article
              doc.set({ //increase count
                count: count + 1
              });
              count++;
            }
          }
        }
        if (window.localStorage && increaseCount) { //mark as visited
          localStorage.setItem(title, true);
        }

        return count;
      });
    }

    function appendCountTo(el) {
      return function(count) {
        $(el).append(
          $('<span>').addClass('post-meta-item')
            .append(
              $('<span>').addClass('post-meta-item-icon').append(
                $('<i>').addClass('fa fa-users')
              )
            )
            .append(
              $('<span>').text('{{ __("post.views")}} ' + count)
            )
        );
      }
    }

    var db = firebase.firestore();
    var articles = db.collection('{{ theme.firestore.collection }}');

    if (CONFIG.page.isPost) { //is article page
      var title = $('.post-title').text().trim();
      var doc = articles.doc(title);

      getCount(doc, true).then(appendCountTo($('.post-meta')));
    } else if (CONFIG.page.isHome) { //is index page
      var promises = $('.post-title').map((i, o) => {
        var title = $(o).text().trim();
        return articles.doc(title);
      }).map(doc => {
        return getCount(doc);
      });
      Promise.all(promises).then(counts => {
        var metas = $('.post-meta')
        counts.forEach((val, idx) => {
          appendCountTo(metas[idx])(val)
        });
      });
    }
  })();
  </script>
{%- endif %}
