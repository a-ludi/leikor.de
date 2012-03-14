function openPopup (href) {
  if(href.search(/\?/) == -1)
    href += '?popup=1';
  else
    href += '&popup=1';
  popup = window.open(href, "_popup", "width=500,height=400,dependent=yes,location=no,menubar=no,toolbar=no,scrollbars=yes");
  popup.focus();
}

function closeAfter(timeout) {
  window.setTimeout('window.close()', timeout)
}

function copyToClipboard(text) {
  window.prompt ("Zum kopieren [Strg+C] drücken. Danach mit [Enter] den Dialog beenden.", text);
}

var MyUtils = {
  URL_TRANSSCRIPTION: new Hash({
    'ä'  : 'ae',     'ö': 'oe',
    'ü'  : 'ue',     'ß': 'ss',
    '&'  : '_und_',  '€': 'euro',
    '@'  : '_at_',   '°': 'grad',
    '\\+': '_plus_', 'µ': 'my'}),
  
  copyAsLogin: function(self, target) {
    var output = $(self).value.toLowerCase();
    MyUtils.URL_TRANSSCRIPTION.each(function(translation) {
      output = output.gsub(translation.key, translation.value);
    });
    output = output.gsub(/[^a-zA-Z0-9]+/, '_').gsub(/(^[_]+|[_]+$)/, '');
    
    $(target).value = output;
  },
  recreatePositionalClasses: function(element) {
    elements = element.parentNode.childElements()
    for(var i=0; i < elements.length; i++) {
      container = elements[i].firstDescendant()
      if(container.hasClassName('last'))
        container.removeClassName('last');
      if(container.hasClassName('first'))
        container.removeClassName('first');
      if(i == 0)
        container.addClassName('first');
      else if(i == elements.length - 1)
        container.addClassName('last');
    }
  },
  replaceSurroundedImage: function(root, new_src, width, height) {
    if(root.childNodes) {
      for(var i = 0; i < root.childNodes.length; i++) {
        node = root.childNodes[i]
        if(node.nodeType == 1 && node.nodeName == 'IMG') {
          node.src = new_src
          if(width != null)
            node.style.width = width
          if(height != null)
            node.style.height = height
          return true;
        }
      }
    } else return false;
  },
  placeAt: function(element, x, y) {
    element.makePositioned();
    element.setStyle({
      position: 'absolute',
      left: x + 'px',
      top:  y + 'px'
    });
  }
}
Element.addMethods(MyUtils);
