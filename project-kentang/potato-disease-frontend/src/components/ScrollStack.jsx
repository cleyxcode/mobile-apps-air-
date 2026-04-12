import { useLayoutEffect, useRef, useCallback } from 'react';
import Lenis from 'lenis';

export const ScrollStackItem = ({ children, itemClassName = '' }) => (
  <div
    className={`scroll-stack-card relative w-full my-8 p-10 rounded-[32px] shadow-[0_0_30px_rgba(0,0,0,0.3)] box-border origin-top will-change-transform ${itemClassName}`.trim()}
    style={{ backfaceVisibility: 'hidden', transformStyle: 'preserve-3d' }}
  >
    {children}
  </div>
);

const ScrollStack = ({
  children,
  className = '',
  itemDistance = 100,
  itemScale = 0.03,
  itemStackDistance = 30,
  stackPosition = '20%',
  scaleEndPosition = '10%',
  baseScale = 0.85,
  scaleDuration = 0.5,
  rotationAmount = 0,
  blurAmount = 0,
  useWindowScroll = false,
  onStackComplete,
}) => {
  const scrollerRef = useRef(null);
  const stackCompletedRef = useRef(false);
  const animationFrameRef = useRef(null);
  const lenisRef = useRef(null);
  const cardsRef = useRef([]);

  const calculateProgress = useCallback((scrollTop, start, end) => {
    if (scrollTop < start) return 0;
    if (scrollTop > end) return 1;
    return (scrollTop - start) / (end - start);
  }, []);

  const parsePercentage = useCallback((value, containerHeight) => {
    if (typeof value === 'string' && value.includes('%')) return (parseFloat(value) / 100) * containerHeight;
    return parseFloat(value);
  }, []);

  const getScrollData = useCallback(() => {
    if (useWindowScroll) return { scrollTop: window.scrollY, containerHeight: window.innerHeight };
    const s = scrollerRef.current;
    return { scrollTop: s.scrollTop, containerHeight: s.clientHeight };
  }, [useWindowScroll]);

  const getElementOffset = useCallback(el => {
    if (useWindowScroll) return el.getBoundingClientRect().top + window.scrollY;
    return el.offsetTop;
  }, [useWindowScroll]);

  const updateCardTransforms = useCallback(() => {
    if (!cardsRef.current.length) return;
    const { scrollTop, containerHeight } = getScrollData();
    const stackPosPx = parsePercentage(stackPosition, containerHeight);
    const scaleEndPosPx = parsePercentage(scaleEndPosition, containerHeight);
    const endEl = useWindowScroll
      ? document.querySelector('.scroll-stack-end')
      : scrollerRef.current?.querySelector('.scroll-stack-end');
    const endTop = endEl ? getElementOffset(endEl) : 0;

    cardsRef.current.forEach((card, i) => {
      if (!card) return;
      const cardTop = getElementOffset(card);
      const triggerStart = cardTop - stackPosPx - itemStackDistance * i;
      const triggerEnd = cardTop - scaleEndPosPx;
      const pinStart = triggerStart;
      const pinEnd = endTop - containerHeight / 2;

      const scaleProgress = calculateProgress(scrollTop, triggerStart, triggerEnd);
      const scale = 1 - scaleProgress * (1 - (baseScale + i * itemScale));
      const rotation = rotationAmount ? i * rotationAmount * scaleProgress : 0;

      let blur = 0;
      if (blurAmount) {
        let topIdx = 0;
        cardsRef.current.forEach((c, j) => {
          if (scrollTop >= getElementOffset(c) - stackPosPx - itemStackDistance * j) topIdx = j;
        });
        if (i < topIdx) blur = Math.max(0, (topIdx - i) * blurAmount);
      }

      let translateY = 0;
      if (scrollTop >= pinStart && scrollTop <= pinEnd) {
        translateY = scrollTop - cardTop + stackPosPx + itemStackDistance * i;
      } else if (scrollTop > pinEnd) {
        translateY = pinEnd - cardTop + stackPosPx + itemStackDistance * i;
      }

      card.style.transform = `translate3d(0,${translateY}px,0) scale(${scale}) rotate(${rotation}deg)`;
      if (blurAmount) card.style.filter = blur > 0 ? `blur(${blur}px)` : '';

      if (i === cardsRef.current.length - 1) {
        const inView = scrollTop >= pinStart && scrollTop <= pinEnd;
        if (inView && !stackCompletedRef.current) { stackCompletedRef.current = true; onStackComplete?.(); }
        else if (!inView && stackCompletedRef.current) stackCompletedRef.current = false;
      }
    });
  }, [itemScale, itemStackDistance, stackPosition, scaleEndPosition, baseScale, rotationAmount, blurAmount, useWindowScroll, onStackComplete, calculateProgress, parsePercentage, getScrollData, getElementOffset]);

  const setupLenis = useCallback(() => {
    const lenisOpts = {
      duration: 1.4,
      easing: t => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
      smoothWheel: true,
      touchMultiplier: 1.5,
      lerp: 0.08,
      syncTouch: true,
    };
    const lenis = useWindowScroll
      ? new Lenis(lenisOpts)
      : new Lenis({ wrapper: scrollerRef.current, content: scrollerRef.current?.querySelector('.scroll-stack-inner'), ...lenisOpts });

    lenis.on('scroll', updateCardTransforms);
    const raf = time => { lenis.raf(time); animationFrameRef.current = requestAnimationFrame(raf); };
    animationFrameRef.current = requestAnimationFrame(raf);
    lenisRef.current = lenis;
  }, [updateCardTransforms, useWindowScroll]);

  useLayoutEffect(() => {
    const scroller = scrollerRef.current;
    if (!scroller) return;
    const cards = Array.from(useWindowScroll ? document.querySelectorAll('.scroll-stack-card') : scroller.querySelectorAll('.scroll-stack-card'));
    cardsRef.current = cards;

    cards.forEach((card, i) => {
      if (i < cards.length - 1) card.style.marginBottom = `${itemDistance}px`;
      card.style.willChange = 'transform, filter';
      card.style.transformOrigin = 'top center';
      card.style.backfaceVisibility = 'hidden';
      card.style.transform = 'translateZ(0)';
    });

    setupLenis();
    updateCardTransforms();

    return () => {
      if (animationFrameRef.current) cancelAnimationFrame(animationFrameRef.current);
      if (lenisRef.current) lenisRef.current.destroy();
      stackCompletedRef.current = false;
      cardsRef.current = [];
    };
  }, [itemDistance, itemScale, itemStackDistance, stackPosition, scaleEndPosition, baseScale, scaleDuration, rotationAmount, blurAmount, useWindowScroll, onStackComplete, setupLenis, updateCardTransforms]);

  const containerClassName = useWindowScroll
    ? `relative w-full ${className}`.trim()
    : `relative w-full h-full overflow-y-auto overflow-x-visible ${className}`.trim();

  return (
    <div ref={scrollerRef} className={containerClassName} style={{ overscrollBehavior: 'contain', WebkitOverflowScrolling: 'touch' }}>
      <div className="scroll-stack-inner pt-[15vh] px-4 md:px-10 pb-[40rem] min-h-screen">
        {children}
        <div className="scroll-stack-end w-full h-px" />
      </div>
    </div>
  );
};

export default ScrollStack;
