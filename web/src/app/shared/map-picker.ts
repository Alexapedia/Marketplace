import {
  AfterViewInit,
  Component,
  ElementRef,
  EventEmitter,
  Input,
  OnDestroy,
  Output,
  viewChild,
} from '@angular/core';
import { TranslatePipe } from '../core/i18n/translate.pipe';

type LeafletNs = {
  map: (el: HTMLElement, opts?: object) => LeafletMap;
  tileLayer: (url: string, opts?: object) => { addTo: (map: LeafletMap) => void };
  marker: (latlng: [number, number]) => LeafletMarker;
};

type LeafletMap = {
  remove: () => void;
  setView: (c: [number, number], z: number) => LeafletMap;
  on: (ev: string, fn: (e: { latlng: { lat: number; lng: number } }) => void) => void;
};

type LeafletMarker = {
  addTo: (map: LeafletMap) => LeafletMarker;
  setLatLng: (c: [number, number]) => void;
};

declare global {
  interface Window {
    L?: LeafletNs;
  }
}

@Component({
  selector: 'app-map-picker',
  imports: [TranslatePipe],
  template: `
    <p class="muted">{{ 'tapMap' | t }}</p>
    <div class="map" #mapEl></div>
  `,
})
export class MapPicker implements AfterViewInit, OnDestroy {
  @Input() lat = 30.0444;
  @Input() lng = 31.2357;
  @Output() coordsChange = new EventEmitter<{ lat: number; lng: number }>();

  private readonly mapEl = viewChild<ElementRef<HTMLElement>>('mapEl');
  private map?: LeafletMap;

  ngAfterViewInit(): void {
    const el = this.mapEl()?.nativeElement;
    const L = window.L;
    if (!el || !L) return;
    this.map = L.map(el).setView([this.lat, this.lng], 13);
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap',
    }).addTo(this.map);
    const marker = L.marker([this.lat, this.lng]).addTo(this.map);
    this.map.on('click', (e) => {
      marker.setLatLng([e.latlng.lat, e.latlng.lng]);
      this.coordsChange.emit({ lat: e.latlng.lat, lng: e.latlng.lng });
    });
    setTimeout(() => this.map?.setView([this.lat, this.lng], 13), 80);
  }

  ngOnDestroy(): void {
    this.map?.remove();
  }
}
