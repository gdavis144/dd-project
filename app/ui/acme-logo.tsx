import { MusicalNoteIcon } from '@heroicons/react/24/outline';
import { lusitana } from '@/app/ui/fonts';

export default function SongbirdLogo() {
  return (
    <div
      className={`${lusitana.className} flex flex-row items-center leading-none text-white`}
    >
      <MusicalNoteIcon className="h-12 w-12 rotate-[15deg] p-1" />
      <p className="text-[40px]">Songbird</p>
    </div>
  );
}
