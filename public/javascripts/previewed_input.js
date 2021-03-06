var PreviewedInput = Class.create({
  initialize: function(input, options) {
    this.initializeWithOptions(input, options);
    this.initializeHTML();
    this.initializeEventHandlers();
    this.extendInput();
  },
  
  initializeWithOptions: function(input, options) {
    options = PreviewedInput.defaultOptions.merge(options || {});
    this.input = $(input);
    this.offset = options.get('offset');
    this.observe = new Object({
      mouse: options.get('observeMouse'),
      focus: options.get('observeFocus')
    });
    this.eventCode = new Object({
      mouseover: options.get('onmouseover'),
      mouseout: options.get('onmouseout'),
      focus: options.get('onfocus'),
      blur: options.get('onblur')
    });
    this.eventHandlerWithCode = function(code) {
      return eval(code);
    }.bind(this.input);
  },
  
  initializeHTML: function() {
    Element.wrap(this.input, 'div', {style: 'position: relative;'});
    this.input.insert({after: new Element('div', {'class': 'preview'})});
    this.preview = this.input.next();
    this.preview.hide();
    this.preview
    this.adjustPreviewToInput();
  },
  
  initializeEventHandlers: function() {
    this.timesShown = 0;
    if(this.observe.mouse) {
      this.input.on('mouseover', this.showPreview.bind(this, this.eventCode.mouseover));
      this.input.on('mouseout', this.hidePreview.bind(this, this.eventCode.mouseout));
    }
    if(this.observe.focus) {
      this.input.on('focus', this.showPreview.bind(this, this.eventCode.focus));
      this.input.on('blur', this.hidePreview.bind(this, this.eventCode.blur));
    }
  },
  
  extendInput: function() {
    Object.extend(this.input, {
      updatePreview: function(content) {
        this.preview.update(content);
      }.bind(this)
    });
  },
  
  adjustPreviewToInput: function() {
    inputDimensions = this.input.getDimensions();
    this.preview.absolutize();
    this.preview.clonePosition(this.input, {
      setLeft: true,
      setTop: true,
      offsetTop: inputDimensions.height + this.offset
    });
    this.preview.setStyle({
      height: 'auto',
      width: this.input.measure('width')
    });
  },
  
  showPreview: function(eventCode) {
    if(this.timesShown <= 0)
      this.preview.show();
    
    this.timesShown++;
    
    return this.eventHandlerWithCode(eventCode);
  },
  
  hidePreview: function(eventCode) {
    this.timesShown--;
    
    if(this.timesShown <= 0)
      this.preview.hide();
    
    return this.eventHandlerWithCode(eventCode);
  }
});

PreviewedInput.defaultOptions = $H({
  offset: 2,
  observeMouse: true,
  observeFocus: true,
  onmouseover: '',
  onmouseout: '',
  onfocus: '',
  onblur: ''
});

var AutocompletedInput = Class.create(PreviewedInput, {
  initialize: function($super, input, options) {
    options = AutocompletedInput.defaultOptions.merge(options || {});
    $super(input, options);
    this.preview.addClassName('suggestions');
    this.preview.hide();
  }
});

AutocompletedInput.defaultOptions = PreviewedInput.defaultOptions.merge({
  observeMouse: false,
  observeFocus: false
});
